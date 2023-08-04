import os
from matplotlib import pyplot as plt
import tensorflow as tf 
import tensorflow_io as tfio
from keras.models import Sequential
from tensorflow.keras.layers import Conv2D
from keras.layers import Dense, Activation, Flatten
from keras.models import load_model
import pyaudio
import tensorflow as tf
import wave
from pydub import AudioSegment
import pydub
def record():
    FRAMES_PER_BUFFER = 3200
    FORMAT = pyaudio.paInt16

    CHANNELS =1

    RATE =16000
    P = pyaudio.PyAudio()#create pyaudio object

    stream = P.open(
        format= FORMAT,
        channels=CHANNELS,
        rate = RATE,
        input =True,
        frames_per_buffer=FRAMES_PER_BUFFER
    )

    print("START RECORDING")

    seconds = 30 #record for 5 seconds
    frames =[]
    for i in range(0,int(RATE/FRAMES_PER_BUFFER*seconds)):
        data = stream.read(FRAMES_PER_BUFFER)#3200 frames in one iteration
        frames.append(data)



    stream.stop_stream()
    stream.close()
    P.terminate()
    
# SAVE FRAMS OBJECT
    obj= wave.open("testingmodel.wav","wb")
    obj.setnchannels(CHANNELS)
    obj.setframerate(RATE)
    obj.setsampwidth(P.get_sample_size(FORMAT))

    obj.writeframes(b"".join(frames))
    obj.close()
    print("closed")


def preprocess(file_path, label): 
    wav = load_wav_16k_mono(file_path)
    wav = wav[:80000]
    zero_padding = tf.zeros([80000] - tf.shape(wav), dtype=tf.float32)
    wav = tf.concat([zero_padding, wav],0)
    spectrogram = tf.signal.stft(wav, frame_length=920, frame_step=43)
    spectrogram = tf.abs(spectrogram)
    spectrogram = tf.expand_dims(spectrogram, axis=2)
    return spectrogram, label

def preprocess_mp3(sample, index):
    sample = sample[0]
    zero_padding = tf.zeros([80000] - tf.shape(sample), dtype=tf.float32)
    wav = tf.concat([zero_padding, sample],0)
    spectrogram = tf.signal.stft(wav, frame_length=920, frame_step=43)
    spectrogram = tf.abs(spectrogram)
    spectrogram = tf.expand_dims(spectrogram, axis=2)
    
    return spectrogram


def load_mp3_16k_mono(filename):
    """ Load a WAV file, convert it to a float tensor, resample to 16 kHz single-channel audio. """
    res = tfio.audio.AudioIOTensor(filename)
    # Convert to tensor and combine channels 
    tensor = res.to_tensor()
    tensor = tf.math.reduce_sum(tensor, axis=1) / 2 
    # Extract sample rate and cast
    sample_rate = res.rate
    sample_rate = tf.cast(sample_rate, dtype=tf.int64)
    # Resample to 16 kHz
    wav = tfio.audio.resample(tensor, rate_in=sample_rate, rate_out=16000)
    return wav


def main():
    i=0
    if i<1: #tempoary while
        print('hi')
        record()
        print('end')
        file = os.path.join('testingmodel.wav')
        wav = load_mp3_16k_mono(file)
    
        audio_slices = tf.keras.utils.timeseries_dataset_from_array(wav, wav, sequence_length=80000, sequence_stride=80000, batch_size=1)
        samples, index = audio_slices.as_numpy_iterator().next()
        audio_slices = tf.keras.utils.timeseries_dataset_from_array(wav, wav, sequence_length=80000, sequence_stride=80000, batch_size=1)
        audio_slices = audio_slices.map(preprocess_mp3)
        audio_slices = audio_slices.batch(64)
    
    # print('                   ',spectrogram)
    
    
  
        model = load_model('newdetection')
        yhat =  model.predict(audio_slices)
        yhat = [1 if prediction > 0.5 else 0 for prediction in yhat]
        i=i+1
        print(yhat)
    



main()



