library(svDialogs)
library(wav)
library(ggplot2)
#filename <- dlgInput("Enter the PDF filename to save plots to", Sys.info()["user"])$res
# read data from CSV
accel_data <- read.csv("./data/03-25-2024, 13-39-43-accel.csv")

# calculate moving average of X
ma_x = filter(accel_data$Accel.X,filter=rep(1/10,10),method='convolution',sides=1)
ma_x_num = seq(0,length(ma_x)-1,by=1)

png(filename="x_ma.png",width=2560,height=1440)
frame <- data.frame(ma_x_num,ma_x)
ggplot(frame,aes(x=ma_x_num,y=ma_x)) + 
  ggtitle("Plot of moving average of X in (m/s^2)") +
  xlab("Sample Number") +
  ylab("Acceleration (m/s^2)") +
  scale_x_continuous(breaks = seq(0, length(ma_x), by = 500)) + 
  scale_y_continuous(breaks = seq(-20, 20, by=0.75))+
  geom_line(color='red') +
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
# calculate moving average of Y
ma_y = filter(accel_data$Accel.Y,filter=rep(1/10,10),method='convolution',sides=1)
ma_y_num = seq(0,length(ma_y)-1,by=1)

png(filename="y_ma.png",width=2560,height=1440)
#plot Moving average of Y
frame <- data.frame(ma_y_num,ma_y)
ggplot(frame,aes(x=ma_y_num,y=ma_y)) +
  ggtitle("Plot of moving average of Y in (m/s^2)") +
  xlab("Sample Number") +
  ylab("Acceleration (m/s^2)") +
  scale_x_continuous(breaks = seq(0, length(ma_y), by = 500)) + 
  scale_y_continuous(breaks = seq(-20, 20, by=0.75))+
  geom_line(color='green') +
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
# calculate moving average of Z
ma_z = filter(accel_data$Accel.Z,filter=rep(1/10,10),method='convolution',sides=1)
ma_z_num = seq(0,length(ma_z)-1,by=1)

png(filename="z_ma.png",width=2560,height=1440)
#plot Moving average of Z
frame <- data.frame(ma_z_num,ma_z)
ggplot(frame,aes(x=ma_z_num,y=ma_z)) + 
  ggtitle("Plot of moving average of Z in (m/s^2)") +
  xlab("Sample Number") +
  ylab("Acceleration (m/s^2)") +
  scale_x_continuous(breaks = seq(0, length(ma_z), by = 500)) + 
  scale_y_continuous(breaks = seq(-20, 20, by=0.75))+
  geom_line(color='blue') +
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