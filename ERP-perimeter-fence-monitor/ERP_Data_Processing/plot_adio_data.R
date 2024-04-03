library(wav)
library(ggplot2)

audio_data <- read.csv("data/climbing_at_panel_Output_mono.csv")
png(filename="audio_climbing_fence_0_panels.png",width=1920,height=1080)
x_axis <- seq(0,length(audio_data$M)-1, by = 1)
frame <- data.frame(x_axis,audio_data$M)
ggplot(frame,aes(x=x_axis,y=audio_data$M)) +
  ggtitle("Audio Waveform Climbing Fence At the Panel") +
  xlab("Sample Number") +
  ylab("ADC Digital Output") +
  scale_x_continuous(breaks = seq(0, length(audio_data$M), by = 4000)) +
  scale_y_continuous(breaks = seq(-2048, 2048, by=256))+
  geom_line(color='black') +
  theme(
    plot.title = element_text(color="black", size=48, face="bold.italic",hjust=0.5),
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    axis.text = element_text(size = 22),
    panel.background = element_rect(fill = "white",
                                    colour = "white",
                                    linewidth = 0.5, linetype = "solid"),
    panel.grid.major = element_line(linewidth = 0.5, linetype = 'solid',
                                    colour = "white"),
    panel.grid.minor = element_line(linewidth = 0.25, linetype = 'solid',
                                    colour = "white")
  )
dev.off()

audio_data <- read.csv("data/climbing_one_panel_away_Output_mono.csv")
png(filename="audio_climbing_fence_1_panels.png",width=1920,height=1080)
x_axis <- seq(0,length(audio_data$M)-1, by = 1)
frame <- data.frame(x_axis,audio_data$M)
ggplot(frame,aes(x=x_axis,y=audio_data$M)) +
  ggtitle("Audio Waveform Climbing Fence One Panel Away") +
  xlab("Sample Number") +
  ylab("ADC Digital Output") +
  scale_x_continuous(breaks = seq(0, length(audio_data$M), by = 4000)) +
  scale_y_continuous(breaks = seq(-2048, 2048, by=256))+
  geom_line(color='black') +
  theme(
    plot.title = element_text(color="black", size=48, face="bold.italic",hjust=0.5),
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    axis.text = element_text(size = 22),
    panel.background = element_rect(fill = "white",
                                    colour = "white",
                                    linewidth = 0.5, linetype = "solid"),
    panel.grid.major = element_line(linewidth = 0.5, linetype = 'solid',
                                    colour = "white"),
    panel.grid.minor = element_line(linewidth = 0.25, linetype = 'solid',
                                    colour = "white")
  )
dev.off()


audio_data <- read.csv("data/climbing_the_fence_two_panels_away_Output_mono.csv")
png(filename="audio_climbing_fence_2_panels.png",width=1920,height=1080)
x_axis <- seq(0,length(audio_data$M)-1, by = 1)
frame <- data.frame(x_axis,audio_data$M)
ggplot(frame,aes(x=x_axis,y=audio_data$M)) +
  ggtitle("Audio Waveform Climbing Fence Two Panels Away") +
  xlab("Sample Number") +
  ylab("ADC Digital Output") +
  scale_x_continuous(breaks = seq(0, length(audio_data$M), by = 4000)) +
  scale_y_continuous(breaks = seq(-2048, 2048, by=256))+
  geom_line(color='black') +
  theme(
    plot.title = element_text(color="black", size=48, face="bold.italic",hjust=0.5),
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    axis.text = element_text(size = 22),
    panel.background = element_rect(fill = "white",
                                    colour = "white",
                                    linewidth = 0.5, linetype = "solid"),
    panel.grid.major = element_line(linewidth = 0.5, linetype = 'solid',
                                    colour = "white"),
    panel.grid.minor = element_line(linewidth = 0.25, linetype = 'solid',
                                    colour = "white")
  )
dev.off()

audio_data <- read.csv("data/climbing_the_fence_to_the_left_Output_mono.csv")
png(filename="audio_climbing_fence_left.png",width=1920,height=1080)
x_axis <- seq(0,length(audio_data$M)-1, by = 1)
frame <- data.frame(x_axis,audio_data$M)
ggplot(frame,aes(x=x_axis,y=audio_data$M)) +
  ggtitle("Audio Waveform Climbing Fence To The Left") +
  xlab("Sample Number") +
  ylab("ADC Digital Output") +
  scale_x_continuous(breaks = seq(0, length(audio_data$M), by = 4000)) +
  scale_y_continuous(breaks = seq(-2048, 2048, by=256))+
  geom_line(color='black') +
  theme(
    plot.title = element_text(color="black", size=48, face="bold.italic",hjust=0.5),
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    axis.text = element_text(size = 22),
    panel.background = element_rect(fill = "white",
                                    colour = "white",
                                    linewidth = 0.5, linetype = "solid"),
    panel.grid.major = element_line(linewidth = 0.5, linetype = 'solid',
                                    colour = "white"),
    panel.grid.minor = element_line(linewidth = 0.25, linetype = 'solid',
                                    colour = "white")
  )
dev.off()

audio_data <- read.csv("data/climbing_the_fence_to_the_right_Output_mono.csv")
png(filename="audio_climbing_fence_right.png",width=1920,height=1080)
x_axis <- seq(0,length(audio_data$M)-1, by = 1)
frame <- data.frame(x_axis,audio_data$M)
ggplot(frame,aes(x=x_axis,y=audio_data$M)) +
  ggtitle("Audio Waveform Climbing Fence To The Right") +
  xlab("Sample Number") +
  ylab("ADC Digital Output") +
  scale_x_continuous(breaks = seq(0, length(audio_data$M), by = 4000)) +
  scale_y_continuous(breaks = seq(-2048, 2048, by=256))+
  geom_line(color='black') +
  theme(
    plot.title = element_text(color="black", size=48, face="bold.italic",hjust=0.5),
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    axis.text = element_text(size = 22),
    panel.background = element_rect(fill = "white",
                                    colour = "white",
                                    linewidth = 0.5, linetype = "solid"),
    panel.grid.major = element_line(linewidth = 0.5, linetype = 'solid',
                                    colour = "white"),
    panel.grid.minor = element_line(linewidth = 0.25, linetype = 'solid',
                                    colour = "white")
  )
dev.off()

audio_data <- read.csv("data/shaking_the_fence_Output_mono.csv")
png(filename="audio_shaking_fence_0_panels.png",width=1920,height=1080)
x_axis <- seq(0,length(audio_data$M)-1, by = 1)
frame <- data.frame(x_axis,audio_data$M)
ggplot(frame,aes(x=x_axis,y=audio_data$M)) +
  ggtitle("Audio Waveform Climbing Fence At the Panel") +
  xlab("Sample Number") +
  ylab("ADC Digital Output") +
  scale_x_continuous(breaks = seq(0, length(audio_data$M), by = 4000)) +
  scale_y_continuous(breaks = seq(-2048, 2048, by=256))+
  geom_line(color='black') +
  theme(
    plot.title = element_text(color="black", size=48, face="bold.italic",hjust=0.5),
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    axis.text = element_text(size = 22),
    panel.background = element_rect(fill = "white",
                                    colour = "white",
                                    linewidth = 0.5, linetype = "solid"),
    panel.grid.major = element_line(linewidth = 0.5, linetype = 'solid',
                                    colour = "white"),
    panel.grid.minor = element_line(linewidth = 0.25, linetype = 'solid',
                                    colour = "white")
  )
dev.off()

audio_data <- read.csv("data/shaking_the_fence_one_panel_away_Output_mono.csv")
png(filename="audio_shaking_fence_1_panels.png",width=1920,height=1080)
x_axis <- seq(0,length(audio_data$M)-1, by = 1)
frame <- data.frame(x_axis,audio_data$M)
ggplot(frame,aes(x=x_axis,y=audio_data$M)) +
  ggtitle("Audio Waveform Shaking Fence One Panel Away") +
  xlab("Sample Number") +
  ylab("ADC Digital Output") +
  scale_x_continuous(breaks = seq(0, length(audio_data$M), by = 4000)) +
  scale_y_continuous(breaks = seq(-2048, 2048, by=256))+
  geom_line(color='black') +
  theme(
    plot.title = element_text(color="black", size=48, face="bold.italic",hjust=0.5),
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    axis.text = element_text(size = 22),
    panel.background = element_rect(fill = "white",
                                    colour = "white",
                                    linewidth = 0.5, linetype = "solid"),
    panel.grid.major = element_line(linewidth = 0.5, linetype = 'solid',
                                    colour = "white"),
    panel.grid.minor = element_line(linewidth = 0.25, linetype = 'solid',
                                    colour = "white")
  )
dev.off()


audio_data <- read.csv("data/shaking_the_fence_2_panels_away_Output_mono.csv")
png(filename="audio_shaking_fence_2_panels.png",width=1920,height=1080)
x_axis <- seq(0,length(audio_data$M)-1, by = 1)
frame <- data.frame(x_axis,audio_data$M)
ggplot(frame,aes(x=x_axis,y=audio_data$M)) +
  ggtitle("Audio Waveform Shaking Fence Two Panels Away") +
  xlab("Sample Number") +
  ylab("ADC Digital Output") +
  scale_x_continuous(breaks = seq(0, length(audio_data$M), by = 4000)) +
  scale_y_continuous(breaks = seq(-2048, 2048, by=256))+
  geom_line(color='black') +
  theme(
    plot.title = element_text(color="black", size=48, face="bold.italic",hjust=0.5),
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    axis.text = element_text(size = 22),
    panel.background = element_rect(fill = "white",
                                    colour = "white",
                                    linewidth = 0.5, linetype = "solid"),
    panel.grid.major = element_line(linewidth = 0.5, linetype = 'solid',
                                    colour = "white"),
    panel.grid.minor = element_line(linewidth = 0.25, linetype = 'solid',
                                    colour = "white")
  )
dev.off()

audio_data <- read.csv("data/shaking_the_fence_to_the_left_Output_mono.csv")
png(filename="audio_shaking_fence_left.png",width=1920,height=1080)
x_axis <- seq(0,length(audio_data$M)-1, by = 1)
frame <- data.frame(x_axis,audio_data$M)
ggplot(frame,aes(x=x_axis,y=audio_data$M)) +
  ggtitle("Audio Waveform Shaking Fence To The Left") +
  xlab("Sample Number") +
  ylab("ADC Digital Output") +
  scale_x_continuous(breaks = seq(0, length(audio_data$M), by = 4000)) +
  scale_y_continuous(breaks = seq(-2048, 2048, by=256))+
  geom_line(color='black') +
  theme(
    plot.title = element_text(color="black", size=48, face="bold.italic",hjust=0.5),
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    axis.text = element_text(size = 22),
    panel.background = element_rect(fill = "white",
                                    colour = "white",
                                    linewidth = 0.5, linetype = "solid"),
    panel.grid.major = element_line(linewidth = 0.5, linetype = 'solid',
                                    colour = "white"),
    panel.grid.minor = element_line(linewidth = 0.25, linetype = 'solid',
                                    colour = "white")
  )
dev.off()

audio_data <- read.csv("data/shaking_the_fence_to_the_right_Output_mono.csv")
png(filename="audio_shaking_fence_right.png",width=1920,height=1080)
x_axis <- seq(0,length(audio_data$M)-1, by = 1)
frame <- data.frame(x_axis,audio_data$M)
ggplot(frame,aes(x=x_axis,y=audio_data$M)) +
  ggtitle("Audio Waveform Shaking Fence To The Right") +
  xlab("Sample Number") +
  ylab("ADC Digital Output") +
  scale_x_continuous(breaks = seq(0, length(audio_data$M), by = 4000)) +
  scale_y_continuous(breaks = seq(-2048, 2048, by=256))+
  geom_line(color='black') +
  theme(
    plot.title = element_text(color="black", size=48, face="bold.italic",hjust=0.5),
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    axis.text = element_text(size = 22),
    panel.background = element_rect(fill = "white",
                                    colour = "white",
                                    linewidth = 0.5, linetype = "solid"),
    panel.grid.major = element_line(linewidth = 0.5, linetype = 'solid',
                                    colour = "white"),
    panel.grid.minor = element_line(linewidth = 0.25, linetype = 'solid',
                                    colour = "white")
  )
dev.off()

audio_data <- read.csv("data/noise_Output_mono.csv")
png(filename="audio_noise.png",width=1920,height=1080)
x_axis <- seq(0,length(audio_data$M)-1, by = 1)
frame <- data.frame(x_axis,audio_data$M)
ggplot(frame,aes(x=x_axis,y=audio_data$M)) +
  ggtitle("Audio Waveform Noise") +
  xlab("Sample Number") +
  ylab("ADC Digital Output") +
  scale_x_continuous(breaks = seq(0, length(audio_data$M), by = 4000)) +
  scale_y_continuous(breaks = seq(-2048, 2048, by=32))+
  geom_line(color='black') +
  theme(
    plot.title = element_text(color="black", size=48, face="bold.italic",hjust=0.5),
    axis.title.x = element_text(size = 22),
    axis.title.y = element_text(size = 22),
    axis.text = element_text(size = 22),
    panel.background = element_rect(fill = "white",
                                    colour = "white",
                                    linewidth = 0.5, linetype = "solid"),
    panel.grid.major = element_line(linewidth = 0.5, linetype = 'solid',
                                    colour = "white"),
    panel.grid.minor = element_line(linewidth = 0.25, linetype = 'solid',
                                    colour = "white")
  )
dev.off()