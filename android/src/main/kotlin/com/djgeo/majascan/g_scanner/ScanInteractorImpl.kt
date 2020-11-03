package com.djgeo.majascan.g_scanner

import android.content.Context
import android.graphics.Canvas
import android.graphics.Rect
import android.util.AttributeSet
import android.view.ViewGroup

import com.google.zxing.Result

import me.dm7.barcodescanner.core.IViewFinder
import me.dm7.barcodescanner.core.ViewFinderView
import me.dm7.barcodescanner.zxing.ZXingScannerView

/**
 * Created by Justin on 2017/2/27.
 */

class ScanInteractorImpl(private val mCallback: ScanCallbackInterface?) : ScanInteractor, ZXingScannerView.ResultHandler {

    private var mZXingScannerView: ZXingScannerView? = null

    interface ScanCallbackInterface {

        fun receiveResult(result: String)
    }

    companion object{
        class MyViewFinder : ViewFinderView {

            constructor(context: Context) : super(context) {}

            constructor(context: Context, attrs: AttributeSet) : super(context, attrs) {}

            override fun onDraw(canvas: Canvas) {}
        }
    }

    override fun initScan(previewContainer: ViewGroup) {
        mZXingScannerView = object : ZXingScannerView(previewContainer.context) {
            override fun createViewFinderView(context: Context): IViewFinder {
                return MyViewFinder(context)
            }

            @Synchronized
            override fun getFramingRectInPreview(previewWidth: Int, previewHeight: Int): Rect {
                return Rect(0, 0, previewWidth, previewHeight)
            }
        }
        mZXingScannerView!!.setResultHandler(this)
        previewContainer.addView(mZXingScannerView)
    }

    override fun startPreview() {
        if (mZXingScannerView != null) {
            mZXingScannerView!!.startCamera()
        }
    }

    override fun stopPreview() {
        if (mZXingScannerView != null) {
            mZXingScannerView!!.stopCamera()
        }
    }

    override fun openFlash() {
        if (mZXingScannerView != null) {
            mZXingScannerView!!.flash = true
        }
    }

    override fun closeFlash() {
        if (mZXingScannerView != null) {
            mZXingScannerView!!.flash = false
        }
    }


    override fun handleResult(result: Result) {
        val text = result.text
        mCallback?.receiveResult(text)
    }
}
