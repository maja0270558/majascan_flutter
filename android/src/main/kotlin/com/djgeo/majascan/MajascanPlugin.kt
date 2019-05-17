package com.djgeo.majascan

import android.app.Activity
import android.app.Activity.RESULT_OK
import android.content.Intent
import com.djgeo.majascan.g_scanner.QrCodeScannerActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar

class MajascanPlugin(activity: Activity) : MethodCallHandler, PluginRegistry.ActivityResultListener {

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val majascanPlugin = MajascanPlugin(registrar.activity())
            val channel = MethodChannel(registrar.messenger(), "majascan")
            channel.setMethodCallHandler(majascanPlugin)

            // 注册ActivityResult回调
            registrar.addActivityResultListener(majascanPlugin)
        }

        const val SCANRESULT = "scan"
        const val Request_Scan = 1
    }

    private var activity: Activity? = activity
    private var mResult: Result? = null

    override fun onMethodCall(call: MethodCall, result: Result) {

        when (call.method) {
            SCANRESULT -> {
                val args: Map<String, String>? = call.arguments()
                activity?.let {
                    val intent = Intent(it, QrCodeScannerActivity::class.java)
                    args?.keys?.map { key -> intent.putExtra(key, args[key]) }
                    it.startActivityForResult(intent, Request_Scan)
                    mResult = result
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == Request_Scan && resultCode == RESULT_OK && data != null) {
            val resultString = data.getStringExtra(QrCodeScannerActivity.BUNDLE_SCAN_CALLBACK)
            resultString?.let {
                mResult?.success(it)
            }
            return true
        }
        return false
    }
}
