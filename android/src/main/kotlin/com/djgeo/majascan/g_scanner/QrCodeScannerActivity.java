package com.djgeo.majascan.g_scanner;

import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.graphics.Color;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.KeyEvent;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.djgeo.majascan.R;

public class QrCodeScannerActivity extends AppCompatActivity {

    public static final int REQUEST_CAMERA = 1;

    //bundle key
    public static final String BUNDLE_SCAN_CALLBACK = "BUNDLE_SCAN_CALLBACK";

    //key from flutter
    public static final String FLASHLIGHT = "FLASHLIGHT";
    public static final String TITLE = "TITLE";
    public static final String TITLE_COLOR = "TITLE_COLOR";
    public static final String BAR_COLOR = "BAR_COLOR";

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
        );
        //鎖定螢幕

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

        //是否有閃光燈按鈕
        boolean hasFlashLight = true;
        if ("0".equals(intent.getStringExtra(FLASHLIGHT))) {
            hasFlashLight = false;
        }

        //toolbar顏色
        int toolbarColor = 0;
        String stringBarColor = intent.getStringExtra(BAR_COLOR);
        if (!TextUtils.isEmpty(stringBarColor) && stringBarColor.indexOf("#") == 0) {
            try {
                toolbarColor = Color.parseColor(stringBarColor);
            } catch (Exception e) {
                Log.e("QrCodeScannerActivity", "parse color code error:" + e);
            }
        }

        int titleColor = 0;
        String stringTitleColor = intent.getStringExtra(TITLE_COLOR);
        if (!TextUtils.isEmpty(stringTitleColor) && stringTitleColor.indexOf("#") == 0) {
            try {
                titleColor = Color.parseColor(stringTitleColor);
            } catch (Exception e) {
                Log.e("QrCodeScannerActivity", "parse color code error:" + e);
            }
        }

        ScanFragment scanFragment = ScanFragment.newInstance(
                intent.getStringExtra(TITLE),
                hasFlashLight,
                toolbarColor,
                titleColor
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
        //攔截back鍵事件，如果是在ScanFragment就強制finish();
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