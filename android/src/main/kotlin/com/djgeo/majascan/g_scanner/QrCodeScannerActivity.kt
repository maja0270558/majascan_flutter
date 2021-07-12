package com.djgeo.majascan.g_scanner


import android.app.Activity
import android.content.Intent
import android.content.pm.ActivityInfo
import android.content.res.Configuration
import android.graphics.Color
import android.os.Bundle
import android.text.TextUtils
import android.util.Log
import android.view.KeyEvent
import androidx.appcompat.app.AppCompatActivity
import com.djgeo.majascan.R


class QrCodeScannerActivity : AppCompatActivity() {

    companion object {

        const val REQUEST_CAMERA = 1

        //bundle key
        const val BUNDLE_SCAN_CALLBACK = "BUNDLE_SCAN_CALLBACK"

        //key from flutter
        const val FLASHLIGHT = "FLASHLIGHT"
        const val TITLE : String = "TITLE"
        const val TITLE_COLOR = "TITLE_COLOR"
        const val BAR_COLOR = "BAR_COLOR"
        const val QR_CORNER_COLOR = "QR_CORNER_COLOR"
        const val QR_SCANNER_COLOR = "QR_SCANNER_COLOR"
        const val SCAN_AREA_SCALE = "SCAN_AREA_SCALE";
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.noActionbarTheme)
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_g_scanner)

        goToScanFragment()

        //鎖定螢幕
        val orientation = resources.configuration.orientation
        Log.d("QrCodeScannerActivity", "QrCodeScannerActivity:$orientation")
        requestedOrientation = if (orientation == Configuration.ORIENTATION_PORTRAIT)
            ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        else
            ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE

    }

    fun goToWebviewFragment(url: String, webTitle: String) {
        val fm = supportFragmentManager
        val webViewFragment = WebViewFragment.newInstance(url, webTitle)
        fm.beginTransaction().replace(R.id.fragment_container, webViewFragment)?.addToBackStack(WebViewFragment::class.java.simpleName)?.commitAllowingStateLoss()
    }

    fun goToScanFragment() {
        intent?.let{
            val fm = supportFragmentManager

            //是否有閃光燈按鈕
            var hasFlashLight = true
            if ("0" == it.getStringExtra(FLASHLIGHT)) {
                hasFlashLight = false
            }

            val scanAreaScale = it.getStringExtra(SCAN_AREA_SCALE)?.toFloat() ?: 0.7F

            val scanFragment = ScanFragment.newInstance(
                    title = intent.getStringExtra(TITLE)!!,
                    hasFlashLight = hasFlashLight,
                    toolBarColor = findColorByBundle(BAR_COLOR),
                    titleColor = findColorByBundle(TITLE_COLOR),
                    qrCornerColor = findColorByBundle(QR_CORNER_COLOR),
                    qrScanColor = findColorByBundle(QR_SCANNER_COLOR),
                    scanAreaScale = scanAreaScale
            )

            fm.beginTransaction().replace(R.id.fragment_container, scanFragment, ScanFragment::class.java.simpleName)?.commitAllowingStateLoss()
        }
    }
    private fun findColorByBundle(bundleKey: String): Int {
        var color = 0
        val stringTitleColor = intent.getStringExtra(bundleKey)
        if (!TextUtils.isEmpty(stringTitleColor) && stringTitleColor!!.indexOf("#") == 0) {
            try {
                color = Color.parseColor(stringTitleColor)
            } catch (e: Exception) {
                Log.e("QrCodeScannerActivity", "parse $bundleKey color code error:$e")
            }
        }
        return color

    }

    fun receiveAndSetResult(result: String) {
        val intent = Intent()
        intent.putExtra(BUNDLE_SCAN_CALLBACK, result)
        setResult(Activity.RESULT_OK, intent)
        finish()
    }

    override fun onKeyUp(keyCode: Int, event: KeyEvent): Boolean {
        //攔截back鍵事件，如果是在ScanFragment就強制finish();
        if (event.action == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_BACK) {
            val fm = supportFragmentManager
            val fragment = fm.findFragmentByTag(ScanFragment::class.java.simpleName)
            if (fragment is ScanFragment) {
                receiveAndSetResult("")
                return true
            }
        }
        return super.onKeyUp(keyCode, event)

    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        val fm = supportFragmentManager
        val fragment = fm.findFragmentByTag(ScanFragment::class.java.simpleName)
        if (fragment is ScanFragment) {
            fragment.onRequestPermissionsResult(requestCode, permissions, grantResults)
        }

    }
}
