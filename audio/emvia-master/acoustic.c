#include <gps.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <stdio.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <bluetooth/bluetooth.h>
#include <bluetooth/rfcomm.h>
#include <errno.h>
#include <signal.h>
#include <assert.h>
#include <alsa/asoundlib.h>
#include <math.h>
#include <time.h>

#define DEBUG

#ifndef DEBUG
#define WRITELOG(str, ...) { \
                        if(_logfile != NULL)\
                        {\
                          struct timespec currtime;\
                          struct tm* utc;\
                          char header[80];\
                          clock_gettime(CLOCK_REALTIME, &currtime);\
                          utc = gmtime((time_t*)&_current_utc);\
                          sprintf(header, "[%ld.%06ld][%02d/%02d/%04d %02d:%02d:%02dUTC] ", \
                                  currtime.tv_sec, currtime.tv_nsec/1000,\
                                  utc->tm_mon+1, utc->tm_mday, utc->tm_year+1900,\
                                  utc->tm_hour, utc->tm_min, utc->tm_sec);\
                          fprintf(_logfile, "%s" str, header, ## __VA_ARGS__);\
                          fflush(_logfile);\
                        }else{printf(str, ## __VA_ARGS__);}\
                      }
#else
#define WRITELOG(str, ...) { \
                        struct timespec currtime;\
                        struct tm* utc;\
                        char header[80];\
                        clock_gettime(CLOCK_REALTIME, &currtime);\
                        utc = gmtime((time_t*)&_current_utc);\
                        sprintf(header, "[%ld.%06ld][%02d/%02d/%04d %02d:%02d:%02dUTC] ", \
                                currtime.tv_sec, currtime.tv_nsec/1000,\
                                utc->tm_mon+1, utc->tm_mday, utc->tm_year+1900,\
                                utc->tm_hour, utc->tm_min, utc->tm_sec);\
                        printf("%s" str, header, ## __VA_ARGS__);\
                      }
#endif
                        /*printf("%s" str, header __VA_OPT__(,) __VA_ARGS__);\ */

#define WRITEAUDIO(buffer, framesize, framecount) { fwrite(buffer, framesize, framecount, _audiofile); fflush(_audiofile); }

#define LED_BLINK_TIME (200000)
#define LED_ON() { fprintf(_led, "255\n"); fflush(_led); }
#define LED_OFF() { fprintf(_led, "0\n"); fflush(_led); }
#define LED_BLINK(x) { LED_OFF(); for(uint32_t _i=0; _i<(x); _i++){ usleep(LED_BLINK_TIME);LED_ON(); usleep(LED_BLINK_TIME); LED_OFF(); } }

// Globals
static bool _shutdown = false;
static bool _poweroff = false;
static pthread_t _gps_thread;
static pthread_t _bt_thread;
static pthread_t _alsa_thread;
static volatile time_t _current_utc;
static volatile uint8_t _miclock;
static volatile uint8_t _gpslock;
static FILE* _audiofile;
static FILE* _logfile;
static FILE* _led;

// Prototypes
static void* gps_thread_entry(void*);
static void* bt_thread_entry(void*);
static void* alsa_thread_entry(void*);
static void intr_handler(int);
static void openfiles();
static void closefiles();

// Main entry point
int main(int argc, char** argv)
{
  // Set up thread interrupt mechanism
  struct sigaction action = {0};
  action.sa_handler = intr_handler;
  assert(sigaction(SIGINT, &action, NULL) == 0);

  _led = fopen("/sys/class/leds/led1/brightness", "w");
  fprintf(_led, "0\n");
  fflush(_led);

  // Spawn GPS thread
  pthread_create(&_gps_thread, NULL, gps_thread_entry, NULL);

  // Spawn recording thread
  pthread_create(&_alsa_thread, NULL, alsa_thread_entry, NULL);

  // Spawn BT interface thread
  pthread_create(&_bt_thread, NULL, bt_thread_entry, NULL);

  // File names depend on UTC time from gps thread
  openfiles();

  // Run until interrupted
  pause();

  // Initiate shutdown
  _shutdown = true;
  WRITELOG("Shutting down\n");
  pthread_kill(_gps_thread, SIGINT);
  pthread_kill(_bt_thread, SIGINT);
  pthread_kill(_alsa_thread, SIGINT);

  pthread_join(_gps_thread, NULL);
  pthread_join(_bt_thread, NULL);
  pthread_join(_alsa_thread, NULL);

  WRITELOG("Done\n");
  if(_poweroff) WRITELOG("Powering off rpi\n");

  closefiles();

  if(_poweroff) system("shutdown -h now");

  return 0;
}

// GPS thread
void* gps_thread_entry(void* args)
{
  struct gps_data_t data;
  int32_t retcode;

  if((retcode = gps_open("localhost", "2947", &data)) == -1)
  {
    printf("Failed to open gps device: %s\n", gps_errstr(retcode));
    exit(1);
  }

  gps_stream(&data, WATCH_ENABLE | WATCH_JSON, NULL);

  while(!_shutdown)
  {
    if(gps_waiting(&data, 50000000))
    {
      if(gps_read(&data) != -1)
      {
        if(data.status == STATUS_FIX)
        {
	  if(_current_utc != data.fix.time)
          {
            _current_utc = data.fix.time;
	  }

          if(data.fix.mode == MODE_2D)
          {
            WRITELOG("Lat/Long:%f,%f Speed:%f\n", data.fix.latitude, data.fix.longitude, data.fix.speed);
          }
          else if(data.fix.mode == MODE_3D)
          {
            WRITELOG("Lat/Long:%f,%f; Altitude:%f ft MSL; Speed:%f\n",
              data.fix.latitude, data.fix.longitude, data.fix.altitude*3.28084, data.fix.speed);
          }
        }
      }
    }
  }

  gps_stream(&data, WATCH_DISABLE, NULL);
  gps_close(&data);

  return NULL;
}

void* bt_thread_entry(void* args)
{
  // Not working for now
  return NULL;

  struct sockaddr_rc local;
  struct sockaddr_rc remote;
  socklen_t addrlen = sizeof(remote);
  int sock = socket(AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);

  local.rc_family = AF_BLUETOOTH;
  local.rc_bdaddr = *BDADDR_ANY;
  local.rc_channel = 1;
  if(bind(sock, (struct sockaddr*)&local, sizeof(local)))
  {
    perror("Failed to bind bt socket");
    exit(1);
  }

  int retval = listen(sock, 0);
  if(retval == -1)
  {
    printf("Listen for bluetooth failed\n");
    exit(1);
  }


  while(!_shutdown)
  {
    struct timeval timeout;
    timeout.tv_sec = 1;
    timeout.tv_usec = 0;

    fd_set fds;
    FD_ZERO(&fds);
    FD_SET(sock, &fds);

    int ret = select(sock+1, &fds, NULL, NULL, &timeout);

    if(ret == -1)
    {
      if(errno != EINTR)
      {
        perror("Select failed");
        break;
      }
      continue;
    }

    if(ret == 0)
    {
      continue;
    }

    if(FD_ISSET(sock, &fds))
    {
      WRITELOG("bt calling accept\n");
      int client = accept(sock, (struct sockaddr*)&remote, &addrlen);
      if(client == -1)
      {
        perror("Failed to accept");
        break;
      }
    }
  }

  close(sock);

  return NULL;
}

void* alsa_thread_entry(void* args)
{
  #define framesize 2 // 16 bits = 2 bytes
  #define bufsize_bytes 9600 // 48k frames/sec -> 4800 frames/100ms -> 9600 bytes/100ms
  static const uint32_t bufsize_frames = bufsize_bytes/framesize;
  static const char* device = "hw:1,0";
  #define HISTORY_LEN 600 // average across 1 minute
  uint8_t history_iter = 0;
  double history_circbuf[HISTORY_LEN];
  uint8_t overavg_count = 0;

  // Fill history with a baseline so it doesn't take so long to level out
  for(uint32_t i = 0; i < HISTORY_LEN; i++)
  {
    history_circbuf[i] = 80.0;
  }


  snd_pcm_t* handle;
  snd_pcm_sframes_t frames;
  static int16_t buffer[bufsize_bytes];

  if(snd_pcm_open(&handle, device, SND_PCM_STREAM_CAPTURE, 0) != 0)
  {
    uint32_t timer = 0;
    printf("Failed to open pcm device (mic not connected)... waiting for mic\n");
    WRITELOG("Failed to open pcm device (mic not connected)... waiting for mic\n");
    fflush(0);
    while(snd_pcm_open(&handle, device, SND_PCM_STREAM_CAPTURE, 0) != 0)
    {
      if(_shutdown)
      {
        WRITELOG("abort!\n");
	printf("abort!\n");
	fflush(0);
	return NULL;
      }
      sleep(1);
      if(timer++ % 5 == 0)
      {
        LED_BLINK(2);
      }
    }
    printf("Found PCM device, continuing\n");
    WRITELOG("Microphone connected, waiting for gps lock\n");
    fflush(0);
  }
  _miclock = 1;

  while(!_gpslock)
  {
    usleep(100000);
  }

  WRITELOG("GPS locked, beginning audio record\n");

  snd_pcm_hw_params_t* params;
  assert(snd_pcm_hw_params_malloc(&params) == 0);
  assert(snd_pcm_hw_params_any(handle, params) == 0);
  assert(snd_pcm_hw_params_set_access(handle, params, SND_PCM_ACCESS_RW_INTERLEAVED) == 0);
  assert(snd_pcm_hw_params_set_format(handle, params, SND_PCM_FORMAT_S16_LE) == 0);
  assert(snd_pcm_hw_params_set_rate(handle, params, 48000, 0) == 0);
  assert(snd_pcm_hw_params_set_channels(handle, params, 1) == 0);
  assert(snd_pcm_hw_params(handle, params) == 0);
  snd_pcm_hw_params_free(params);

  assert(snd_pcm_prepare(handle) == 0);
  assert(snd_pcm_start(handle) == 0);

  while(!_shutdown)
  {
    frames = snd_pcm_readi(handle, buffer, bufsize_frames);
    if(frames < 0)
    {
      if(errno == ENODEV)
      {
        WRITELOG("Microphone disconnected, shutting down\n");
	_poweroff = true;
        _shutdown = true;
        kill(getpid(), SIGINT);
        return NULL;
      }
      WRITELOG("Acoustic readi failed: %s\n", snd_strerror(frames));
      snd_pcm_recover(handle, frames, 0);
      continue;
    }
    else if((frames < bufsize_frames) && !_shutdown)
    {
      WRITELOG("Acoustic underrun occurred\n");
    }

    WRITEAUDIO(buffer, sizeof(buffer[0]), frames);

    uint64_t total = 0;
    uint32_t i = 0;
    for(i = 0; i < frames; i++)
    {
      total += (buffer[i]) * (buffer[i]);
    }

    double rms = sqrt(total*1.0/frames);
    double rollingavg = 0.0f;

    for(i = 0; i < HISTORY_LEN; i++)
    {
      rollingavg += history_circbuf[i];
    }
    rollingavg /= HISTORY_LEN;

    if(rms > rollingavg)
    {
      overavg_count++;
    }
    else
    {
      overavg_count = 0;
    }

    /* don't use LED for this right now
    if(overavg_count >= 10)
    {
      LED_ON();
    }
    else
    {
      LED_OFF();
    }
    */

    history_circbuf[history_iter++] = rms;
    history_iter %= HISTORY_LEN;

    if(history_iter & 1)
    {
      LED_ON();
    }
    else
    {
      LED_OFF();
    }

    WRITELOG("Acoustic RMS:%7.2f Rolling Average:%7.2f overavg_count:%3d\n", rms, rollingavg, overavg_count);
  }

  assert(snd_pcm_close(handle) == 0);

  return NULL;
}

void intr_handler(int sig)
{
  // Thread syscalls will be interrupted
  _shutdown = true;
}

void openfiles()
{
  char filename[80];
  struct tm* utc;
  uint32_t timeout = 60*2;
  struct stat filestat;
  uint32_t unique = 0;

  printf("Waiting for GPS time acquisition...\n");

  while(_current_utc == 0)
  {
    sleep(1);
    timeout--;
    if(timeout % 5 == 0 && _miclock)
    {
      LED_BLINK(3);
    }

    if(_shutdown)
    {
      printf("abort!\n");
      LED_OFF();
      fclose(_led);
      exit(1);
    }

    if(timeout == 0 && _miclock && _current_utc == 0)
    {
      // Don't wait for gps anymore, timed out...
      _current_utc = 1541800892;
      printf("GPS time acquisition failed, defaulting to whatever time Steve picked\n");
    }
  }

  sleep(1);

  if(timeout != 0)
  {
    LED_BLINK(2);
  }
  else
  {
    LED_BLINK(6);
  }

  utc = gmtime((time_t*)&_current_utc);

  do
  {
    sprintf(filename, "logfile.%02d%02d%04d-%02d%02d%02dUTC_%d.txt",
        utc->tm_mon+1, utc->tm_mday, utc->tm_year+1900,
        utc->tm_hour, utc->tm_min, utc->tm_sec, unique++);
  }
  while(stat(filename, &filestat) == 0);

  _logfile = fopen(filename, "w");
  assert(_logfile != NULL);

  sprintf(filename, "recording.%02d%02d%04d-%02d%02d%02dUTC_%d.pcm",
      utc->tm_mon+1, utc->tm_mday, utc->tm_year+1900,
      utc->tm_hour, utc->tm_min, utc->tm_sec, unique);

  _audiofile = fopen(filename, "wb");
  assert(_logfile != NULL);

  WRITELOG("GPS lock acquired, logfile output enabled; mic %s locked\n", (_miclock)?"is":"is not");
  if(!_miclock) WRITELOG("Waiting for mic lock...\n");
  _gpslock = 1;
}

void closefiles()
{
  fflush(_audiofile);
  fclose(_audiofile);

  fflush(_logfile);
  fclose(_logfile);

  fprintf(_led, "0\n");
  fclose(_led);
}

