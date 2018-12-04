package se.podcast.youtube.mp3.youtubepodcaster;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

import java.nio.ByteBuffer;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.ActivityLifecycleListener;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

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
}
