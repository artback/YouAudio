package se.podcast.youtube.mp3.youtubepodcaster;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;


import com.liulishuo.okdownload.DownloadTask;

import java.io.File;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "com.yaudio";
  private String sharedText;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    Intent intent = getIntent();
    String action = intent.getAction();
    String type = intent.getType();
    boolean intentError;

    if (Intent.ACTION_SEND.equals(action) && type != null) {
      if ("text/plain".equals(type)) {
        intentError = handleSendText(intent); // Handle text being sent
        if(intentError) {
          finish();
        }
      }
    }
      new MethodChannel(getFlutterView(), "app.channel.shared.data").setMethodCallHandler(
              new MethodChannel.MethodCallHandler() {
                @Override
                public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                  if (call.method.contentEquals("getSharedText")) {
                    result.success(sharedText);
                    sharedText = null;
                  }
                }
              });
      new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                  @Override
                  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                    if (call.method.contentEquals("download")) {
                      Audio audio =new Audio(
                          (String) call.argument("title"),
                          (String) call.argument("url"),
                          (String) call.argument("folder"),
                          (String) call.argument("file_ending"),
                          (String) call.argument("author")
                      );
                      download(audio);
                    }
                  }
                });
  }
  boolean handleSendText(Intent intent) {
    boolean intentError = false;
    String extra =  intent.getStringExtra(Intent.EXTRA_TEXT);
    if(extra.contains("youtube")) {
      sharedText = intent.getStringExtra(Intent.EXTRA_TEXT);
    }else{
      Context context = getApplicationContext();
      int duration = Toast.LENGTH_SHORT;
      CharSequence text = String.format("Error: %s is not a valid Youtube link",extra);
      Toast.makeText(context, text , duration).show();
      intentError = true;
    }
    return intentError;
  }
  private void download(Audio audio){
    DownloadTask task = new DownloadTask.Builder(audio.url, new File(audio.folder))
            .setFilename(audio.title + '.' + audio.fileEnding)
            // the minimal interval millisecond for callback progress
            .setMinIntervalMillisCallbackProcess(30)
            // do re-download even if the task has already been completed in the past.
            .setPassIfAlreadyCompleted(true)
            .build();
    NotificationListener listener = new NotificationListener(getApplicationContext());
    listener.initNotification(audio);
    task.enqueue(listener);

  }
}
