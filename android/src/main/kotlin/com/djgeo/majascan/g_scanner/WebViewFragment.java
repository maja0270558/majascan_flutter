package com.djgeo.majascan.g_scanner;

import android.graphics.Color;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;


import com.djgeo.majascan.R;

public class WebViewFragment extends Fragment {

    public static final String BUNDLE_URL = "BUNDLE_URL";


    public static WebViewFragment newInstance(String url, String title) {
        Bundle args = new Bundle();
        args.putString(BUNDLE_URL, url);
//        args.putString(BUNDLE_WEBVIEW_TITLE, title);
        WebViewFragment fragment = new WebViewFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_webview, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        final ProgressBar progressBar = view.findViewById(R.id.pb_hori_loading);
        final TextView tvTitle = view.findViewById(R.id.tv_title);
        final WebView webView = view.findViewById(R.id.webview);
        final ImageView backBtn = view.findViewById(R.id.back_btn);

        backBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
//                FragmentManager fm = getFragmentManager();
//                if (fm != null) {
//                    fm.popBackStack();
//                }

                if (getActivity() != null) {
                    getActivity().finish();
                }
            }
        });

        Bundle bundle = getArguments();
        if (bundle != null) {
//            tvTitle.setText(bundle.getString(BUNDLE_WEBVIEW_TITLE, ""));
            progressBar.getProgressDrawable().setColorFilter(
                    Color.rgb(50, 150, 251), android.graphics.PorterDuff.Mode.SRC_IN);//設定進度條的顏色
            webView.setWebChromeClient(new WebChromeClient() {
                @Override
                public void onProgressChanged(WebView view, int newProgress) {
                    //loading進度條的監聽
                    if (progressBar != null) {
                        if (newProgress == 100) {
                            progressBar.setVisibility(ProgressBar.GONE);
                            return;
                        }
                        progressBar.setProgress(newProgress);
                    }
                }
            });

            webView.loadUrl(bundle.getString(BUNDLE_URL, ""));
        }
    }
}
