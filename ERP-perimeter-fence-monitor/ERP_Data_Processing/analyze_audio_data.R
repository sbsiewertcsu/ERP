library(wav)
library(ggplot2)
audio_data <- read.csv("./data/decoded.csv")

png(filename="audio.png",width=1920,height=1080)
x_axis <- seq(0,length(audio_data$ADC.Value)-1, by = 1)
frame <- data.frame(x_axis,audio_data$ADC.Value)
ggplot(frame,aes(x=x_axis,y=audio_data$ADC.Value)) +
ggtitle("Audio Waveform") +
  xlab("Sample Number") +
  ylab("ADC Value after DC offset removal") +
  scale_x_continuous(breaks = seq(0, length(audio_data$ADC.Value), by = 100000)) + 
  scale_y_continuous(breaks = seq(-2048, 2048, by=256))+
  geom_line(color='black') +
  theme(
    plot.title = element_text(color="black", size=48, face="bold.italic",hjust=0.5),
    axis.title.x = element_text(size = 16),
    axis.title.y = element_text(size = 16),
    axis.text = element_text(size = 14),
    panel.background = element_rect(fill = "white",
                                    colour = "white",
                                    size = 0.5, linetype = "solid"),
    panel.grid.major = element_line(size = 0.5, linetype = 'solid',
                                    colour = "white"), 
    panel.grid.minor = element_line(size = 0.25, linetype = 'solid',
                                    colour = "white")
  )
dev.off()

audio <- matrix(audio_data$ADC.Value,nrow=1)
write_wav(audio,"audio.wav",sample_rate=8000,bit_depth=16,normalize=FALSE)
