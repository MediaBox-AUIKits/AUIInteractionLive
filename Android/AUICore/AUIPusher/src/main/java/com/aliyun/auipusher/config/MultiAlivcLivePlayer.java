package com.aliyun.auipusher.config;

import android.content.Context;

import com.alivc.live.annotations.AlivcLiveMode;
import com.alivc.live.player.AlivcLivePlayInfoListener;
import com.alivc.live.player.AlivcLivePlayerImpl;
import com.alivc.live.player.annotations.AlivcLivePlayError;
import com.aliyun.auipusher.listener.MultiInteractLivePushPullListener;

/**
 * AlivcLivePlayer 封装类，用于多人连麦互动
 */
public class MultiAlivcLivePlayer extends AlivcLivePlayerImpl {

    private MultiInteractLivePushPullListener mListener;
    private boolean mIsPlaying = false;
    private String mRtcPullUrl;

    public MultiAlivcLivePlayer(Context context, AlivcLiveMode mode) {
        super(context, mode);
        setPlayInfoListener(new AlivcLivePlayInfoListener() {
            @Override
            public void onPlayStarted() {
                mIsPlaying = true;
                if (mListener != null) {
                    mListener.onPullSuccess(mRtcPullUrl);
                }
            }

            @Override
            public void onPlayStopped() {
                mIsPlaying = false;
                if (mListener != null) {
                    mListener.onPullStop(mRtcPullUrl);
                }
            }

            @Override
            public void onError(AlivcLivePlayError alivcLivePlayError, String s) {
                mIsPlaying = false;
                if (mListener != null) {
                    mListener.onPullError(mRtcPullUrl, alivcLivePlayError, s);
                }
            }
        });
    }

    public void setMultiInteractPlayInfoListener(MultiInteractLivePushPullListener listener) {
        this.mListener = listener;
    }

    public boolean isPulling() {
        return mIsPlaying;
    }

    public String getAudienceId() {
        return mRtcPullUrl;
    }

    public void setAudienceId(String rtcPullUrl) {
        this.mRtcPullUrl = rtcPullUrl;
    }
}
