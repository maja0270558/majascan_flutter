package com.djgeo.majascan.g_scanner;

import android.view.ViewGroup;

public interface ScanInteractor {

    void initScan(ViewGroup previewContainer);

    void startPreview();

    void stopPreview();

    void openFlash();

    void closeFlash();

}