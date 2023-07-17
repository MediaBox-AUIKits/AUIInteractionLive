//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by FernFlower decompiler)
//

package com.alivc.auicommon.common.base.util;

import android.util.Pair;

import org.apache.commons.codec.binary.Base64;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Random;

public class TokenParser {

    public static String encodeTokenAndUrl(String token, String url) {
        try {
            JSONArray endpoints = new JSONArray();
            endpoints.put(url);

            JSONObject jsonObject = new JSONObject();
            jsonObject.put("token", token);
            jsonObject.put("endpoints", endpoints);

            String jsonStr = jsonObject.toString();
            return base64Encode(jsonStr);
        } catch (JSONException var6) {
            var6.printStackTrace();
            throw new RuntimeException("Token编码失败: " + var6.getMessage());
        }
    }

    public static Pair<String, String> decodeTokenAndUrl(String accessToken) {
        try {
            String decodedAccessToken = base64Decode(accessToken);
            JSONObject jsonObject = new JSONObject(decodedAccessToken);
            String actualToken = jsonObject.optString("token");
            JSONArray endpoints = jsonObject.optJSONArray("endpoints");
            if (endpoints == null) {
                throw new RuntimeException("Invalid access token format: " + accessToken);
            } else {
                String endpoint = endpoints.getString((new Random()).nextInt(endpoints.length()));
                return new Pair<>(actualToken, endpoint);
            }
        } catch (JSONException var6) {
            var6.printStackTrace();
            throw new RuntimeException("Token解码失败: " + var6.getMessage());
        }
    }

    private static String base64Encode(String str) {
        return new String(Base64.encodeBase64String(str.getBytes()));
    }

    private static String base64Decode(String str) {
        return new String(Base64.decodeBase64(str));
    }
}
