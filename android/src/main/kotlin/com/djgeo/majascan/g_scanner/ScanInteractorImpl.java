package com.djgeo.majascan.g_scanner;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.ViewGroup;

import com.google.zxing.Result;

import me.dm7.barcodescanner.core.IViewFinder;
import me.dm7.barcodescanner.core.ViewFinderView;
import me.dm7.barcodescanner.zxing.ZXingScannerView;

/**
 * Created by Justin on 2017/2/27.
 */

public class ScanInteractorImpl implements ScanInteractor, ZXingScannerView.ResultHandler {

    private ZXingScannerView mZXingScannerView;

    public ScanInteractorImpl(ScanCallbackInterface mCallback) {
        this.mCallback = mCallback;
    }

    private ScanCallbackInterface mCallback;

    public interface ScanCallbackInterface{

        void receiveResult(String result);
    }

    @Override
    public void initScan(final ViewGroup previewContainer) {
        mZXingScannerView = new ZXingScannerView(previewContainer.getContext()) {
            @Override
            protected IViewFinder createViewFinderView(Context context) {
                return new ScanInteractorImpl.MyViewFinder(context);
            }

            @Override
            public synchronized Rect getFramingRectInPreview(int previewWidth, int previewHeight) {
                return new Rect(0, 0, previewWidth, previewHeight);
            }
        };
        mZXingScannerView.setResultHandler(this);
        previewContainer.addView(mZXingScannerView);
    }

    @Override
    public void startPreview() {
        if (mZXingScannerView != null) {
            mZXingScannerView.startCamera();
        }
    }

    @Override
    public void stopPreview() {
        if (mZXingScannerView != null) {
            mZXingScannerView.stopCamera();
        }
    }

    @Override
    public void openFlash() {
        if (mZXingScannerView != null) {
            mZXingScannerView.setFlash(true);
        }
    }

    @Override
    public void closeFlash() {
        if (mZXingScannerView != null) {
            mZXingScannerView.setFlash(false);
        }
    }


    @Override
    public void handleResult(Result result) {
        String text = result.getText();
        if (mCallback != null) {
            mCallback.receiveResult(text);
        }

        // If you would like to resume scanning, call this method below:
        mZXingScannerView.resumeCameraPreview(this);
    }

    class MyViewFinder extends ViewFinderView {

        public MyViewFinder(Context context) {
            super(context);
        }

        public MyViewFinder(Context context, AttributeSet attrs) {
            super(context, attrs);
        }

        @Override
        public void onDraw(Canvas canvas) {
        }
    }

}
