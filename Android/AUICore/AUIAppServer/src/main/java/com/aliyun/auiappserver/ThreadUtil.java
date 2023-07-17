package com.aliyun.auiappserver;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.Nullable;

import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

public class ThreadUtil {

    private static final String TAG = "ThreadUtil";

    private static final ThreadPoolExecutor THREAD_POOL_EXECUTOR;
    private static final int CPU_COUNT = Runtime.getRuntime().availableProcessors();
    private static final int CORE_POOL_SIZE = Math.max(2, Math.min(CPU_COUNT - 1, 4));
    private static final int MAXIMUM_POOL_SIZE = CPU_COUNT * 2 + 1;
    private static final int KEEP_ALIVE_SECONDS = 30;

    private static final BlockingQueue<Runnable> POOL_WORK_QUEUE =
            new LinkedBlockingQueue<>(128);

    private static final Handler UI_HANDLER = new Handler(Looper.getMainLooper());

    private static final ThreadFactory THREAD_FACTORY = new ThreadFactory() {
        private final AtomicInteger mCount = new AtomicInteger(1);

        @Override
        public Thread newThread(Runnable r) {
            return new Thread(r, "ThreadUtil #" + mCount.getAndIncrement());
        }
    };

    static {
        ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(
                CORE_POOL_SIZE, MAXIMUM_POOL_SIZE, KEEP_ALIVE_SECONDS, TimeUnit.SECONDS,
                POOL_WORK_QUEUE, THREAD_FACTORY);
        threadPoolExecutor.allowCoreThreadTimeOut(true);
        THREAD_POOL_EXECUTOR = threadPoolExecutor;
    }

    public static boolean isMainThread() {
        return Looper.myLooper() == Looper.getMainLooper();
    }

    public static void runOnUiThread(@Nullable Runnable task) {
        if (task == null) {
            return;
        }
        if (isMainThread()) {
            task.run();
        } else {
            postUi(task);
        }
    }

    public static void postUi(@Nullable Runnable task) {
        if (task == null) {
            return;
        }
        UI_HANDLER.post(task);
    }

    public static void postUiDelay(long delayMillis, Runnable runnable) {
        if (runnable == null) {
            return;
        }
        UI_HANDLER.postDelayed(runnable, delayMillis);
    }

    public static void cancel(Runnable runnable) {
        UI_HANDLER.removeCallbacks(runnable);
    }

    public static void runOnSubThread(Runnable runnable) {
        if (THREAD_POOL_EXECUTOR.getQueue().size() == 128 || THREAD_POOL_EXECUTOR.isShutdown()) {
            return;
        }
        THREAD_POOL_EXECUTOR.execute(runnable);
    }
}
