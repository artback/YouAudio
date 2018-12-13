package se.podcast.youtube.mp3.youtubepodcaster;

import java.io.File;

public class Audio{
    String title;
    File file;
    String url;
    String folder;
    String fileEnding;
    String Author;
    Audio(String name, String url, String folder, String fileEnding, String author) {
        this.title= name;
        this.file = new File(folder +'/'+name+'.'+ fileEnding);
        this.url = url;
        this.folder = folder;
        this.fileEnding = fileEnding;
        Author = author;
    }

}
