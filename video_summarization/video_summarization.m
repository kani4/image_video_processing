clc;
close all;
clear all;
VID = VideoReader('proj.3gp') 
%       constructs object names VID to read video data from the file named 'proj.3gp'
%       If it cannot construct the object for any reason, VideoReader generates an error.
no_of_frames=VID.NumberOfFrames
%       gets the number of frames and display
bin_width = 1;
%       binwidth can be set to any value based on the resolution needed.
%       If bin_width is LESS the RESOLUTION will be MORE.  %As it INCREASES the RESOLUTION will be LESS.
bins = 0:bin_width:255;
cluster = [];
match =20;
%       match is the threshold set in percentage that is 30
%       the value for threshold is set as 30 by trial and error
unq = 1; 
%       unq is index for the keyframes being collected.

diff = [];
op_vid = VideoWriter('out.avi','Uncompressed AVI');
%       constructs a VideoWriter object named op_vid
%       To write video data to an AVI file (here named 'story_board10.avi')
%       uses the profile uncompressed RGB4 
open(op_vid);
%       opens the VideoReader object op_vid so that images can be written into the videofile
for i = 1:no_of_frames
    % a for loop is put up for the total number of frames
        my_frame=read(VID,i);
       current_frame = rgb2gray(my_frame);   
    %       a variable current frame is taken and in that variable the frames of the video are read one by one and coverted from rgb to gray  
    clus_size = size(cluster,3);  
    %       the number of images in the third matrix dimension of the matrix cluster is stored in the variable clus_size  
    if i == 1       
        cluster(:,:,1) = histc(current_frame(:),bins)';              
    %       the histogram of the first frame is stored in the cluster matrix
    %       the cluster matrix will get updated in future with the histograms of the remaining key frames
    %       current_frame is a 2-D matrix,to find the histogram of this matrix we convert it to one dimensional matrix by using currentframe(:)
    %       so we by specifying histc(current_frame(:),bins),the number of values between each bin range is found out   
        writeVideo(op_vid,my_frame);
    %       writes the first frame into the video file 
        unq = unq + 1; 
    %      unq is the number of key frames and it is incremented now     
        continue;
    end
    frame_hist = histc(current_frame(:),bins)';    
    %       the histogram of the next image is found by using the same procedure mentioned for the first frame and stored in frame-hist
    diff_clus = [];
    for j = 1:clus_size
        kmeans(j,2,’dist’, ‘sqeuclidean’);
        current_cluster = cluster(:,:,j);
    %       the histograms of the keyframes stored in the cluster are taken one by one
        diff_clus = [diff_clus sum(abs(frame_hist - current_cluster))/(size(current_frame,1)*size(current_frame,2))*100];    
    %difference between the framehist(the histogram of the frame considerd) and current_cluster(the histogram of the various keyframes in the cluster)is found 
    %the differnce values are stored in the diff_clus 
    end
    diff = [diff min(diff_clus)];
    
    %       the minimum value of diff_clus is put up in diff for each frame considered
    if min(diff_clus) > match
    %       if the minimum value of diff_clus is greater than the threshold(match=30), then this loop is entered 
    %       or else the particular frame is just left out because it is not a key frame
        cluster(:,:,unq) = frame_hist;  
    %       if minimum of diff_clus is the greater than match the particular frame is a keyframe
    %       so the histogram of the frame(frame_hist) is added to the cluster
        writeVideo(op_vid,my_frame);
    %       writes the keyframe into the video file
        unq = unq + 1
    %       the number of key frame is incremented
    end   
end
unq = unq – 1;
%       finally the number of key frames is subtracted by one because initialization for unq (keyframes) is done as one
reduction_factor = (1-((unq > 1)*unq)/no_of_frames)*100
%       reduction factor is found out using the formula (unq/no_of_frames)*100
unq
plot(diff);
% a graph is plotted for diff

close(op_vid);
% the video file is closed
implay('story_board10.avi')
%the video file is played using the implay function
