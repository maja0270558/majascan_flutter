package com.djgeo.majascan.g_scanner;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.KeyEvent;

import com.djgeo.majascan.R;

public class QrCodeScannerActivity extends AppCompatActivity {

    public static final int REQUEST_CAMERA = 1;

    //bundle key
    public static final String BUNDLE_SCAN_CALLBACK = "BUNDLE_SCAN_CALLBACK";
    public static final String BUNDLE_HAS_FLASHLIGHT = "BUNDLE_HAS_FLASHLIGHT";
    public static final String BUNDLE_WEBVIEW_TITLE = "BUNDLE_WEBVIEW_TITLE";
    public static final String BUNDLE_TITLE = "BUNDLE_TITLE";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setTheme(R.style.noActionbarTheme);
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_g_scanner);

        goToScanFragment();

        int orientation = getResources().getConfiguration().orientation;
        Log.d("QrCodeScannerActivity", "QrCodeScannerActivity:" + orientation);
        setRequestedOrientation(
                orientation == Configuration.ORIENTATION_PORTRAIT ?
                        ActivityInfo.SCREEN_ORIENTATION_PORTRAIT :
                        ActivityInfo.SCREEN_ORIENTATION_USER_LANDSCAPE
        );//鎖定直屏
//        ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE
    }


    public void goToWebviewFragment(final String url, final String webTitle) {
        FragmentManager fm = getSupportFragmentManager();
        WebViewFragment webViewFragment = WebViewFragment.newInstance(url, webTitle);
        if (fm != null) {
            fm.beginTransaction()
                    .replace(R.id.fragment_container, webViewFragment)
                    .addToBackStack(WebViewFragment.class.getSimpleName())
                    .commitAllowingStateLoss();
        }
    }

    public void goToScanFragment() {
        Intent intent = getIntent();
        FragmentManager fm = getSupportFragmentManager();
        ScanFragment scanFragment = ScanFragment.newInstance(
                intent.getStringExtra(BUNDLE_WEBVIEW_TITLE),
                intent.getBooleanExtra(BUNDLE_HAS_FLASHLIGHT, true),
                intent.getStringExtra(BUNDLE_TITLE)
        );
        if (fm != null) {
            fm.beginTransaction()
                    .replace(R.id.fragment_container, scanFragment, ScanFragment.class.getSimpleName())
                    .commitAllowingStateLoss();
        }
    }

    public void receiveAndSetResult(String result) {
        Intent intent = new Intent();
        intent.putExtra(BUNDLE_SCAN_CALLBACK, result);
        setResult(RESULT_OK, intent);
        finish();
    }

    @Override
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        //攔截back鍵事件，如果是在webViewFragment就強制finish();
        if (event.getAction() == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_BACK) {
            FragmentManager fm = getSupportFragmentManager();
            if (fm != null) {
                Fragment fragment = fm.findFragmentByTag(ScanFragment.class.getSimpleName());
                if (fragment instanceof ScanFragment) {
                    finish();
                    return true;
                }
            }
        }
        return super.onKeyUp(keyCode, event);

    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String permissions[], int[] grantResults) {
        FragmentManager fm = getSupportFragmentManager();
        if (fm != null) {
            Fragment fragment = fm.findFragmentByTag(ScanFragment.class.getSimpleName());
            if (fragment instanceof ScanFragment) {
                fragment.onRequestPermissionsResult(requestCode, permissions, grantResults);
            }
        }

    }
}