package com.aliyun.aliinteraction.uikit.uibase.util;

import android.text.TextUtils;

import androidx.annotation.IntRange;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.alivc.auicommon.common.base.util.Utils;
import com.aliyun.aliinteraction.uikit.uibase.helper.SpHelper;

/**
 * Created by KyleCe on 2021/7/2
 */
public class UserHelper {
    private static final int RANDOM_ID_LEN = 6;
    private static final String[] ALTERNATIVE_ID_ARR = {
            "Wade", "Dave", "Seth", "Ivan", "Riley", "Gilbert", "Jorge", "Dan", "Brian", "Roberto", "Ramon", "Miles", "Liam", "Nathaniel", "Ethan", "Lewis", "Milton", "Claude", "Joshua"
            , "Glen", "Harvey", "Blake", "Antonio", "Connor", "Julian", "Aidan", "Harold", "Conner", "Peter", "Hunter", "Eli", "Alberto", "Carlos", "Shane", "Aaron", "Marlin", "Paul"
            , "Ricardo", "Hector", "Alexis", "Adrian", "Kingston", "Douglas", "Gerald", "Joey", "Johnny", "Charlie", "Scott", "Martin", "Tristin", "Troy", "Tommy", "Rick", "Victor"
            , "Jessie", "Neil", "Ted", "Nick", "Wiley", "Morris", "Clark", "Stuart", "Orlando", "Keith", "Marion", "Marshall", "Noel", "Everett", "Romeo", "Sebastian", "Stefan"
            , "Robin", "Clarence", "Sandy", "Ernest", "Samuel", "Benjamin", "Luka", "Fred", "Albert", "Greyson", "Terry", "Cedric", "Joe", "Paul", "George", "Bruce", "Christopher"
            , "Mark", "Ron", "Craig", "Philip", "Jimmy", "Arthur", "Jaime", "Perry", "Harold", "Jerry", "Shawn", "Walter", "Daisy", "Deborah", "Isabel", "Stella", "Debra", "Beverly", "Vera"
            , "Angela", "Lucy", "Lauren", "Janet", "Loretta", "Tracey", "Beatrice", "Sabrina", "Melody", "Chrysta", "Christina", "Vicki", "Molly", "Alison", "Miranda", "Stephanie", "Leona", "Katrina", "Mila"
            , "Teresa", "Gabriela", "Ashley", "Nicole", "Valentina", "Rose", "Juliana", "Alice", "Kathie", "Gloria", "Luna", "Phoebe", "Angelique", "Graciela", "Gemma", "Katelynn", "Danna", "Luisa", "Julie", "Olive"
            , "Carolina", "Harmony", "Hanna", "Anabelle", "Francesca", "Whitney", "Skyla", "Nathalie", "Sophie", "Hannah", "Silvia", "Sophia", "Della", "Myra", "Blanca", "Bethany", "Robyn", "Traci", "Desiree", "Laverne"
            , "Patricia", "Alberta", "Lynda", "Cara", "Brandi", "Janessa", "Claudia", "Rosa", "Sandra", "Eunice", "Kayla", "Kathryn", "Rosie", "Monique", "Maggie", "Hope", "Alexia", "Lucille", "Odessa", "Amanda", "Kimberly"
            , "Blanche", "Tyra", "Helena", "Kayleigh", "Lucia", "Janine", "Maribel", "Camille", "Alisa", "Vivian", "Lesley", "Rachelle", "Kianna",
    };

    public static String parseUserId() {
        return parseUserId("");
    }

    public static String parseUserId(CharSequence defVal) {
        UserSp userSp = SpHelper.getInstance(UserSp.class);

        return Utils.acceptFirstNotEmpty(userSp.getUserId(), defVal, UserHelper.generateRandomUserId());
    }

    public static void storeUserId(@Nullable String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }

        UserSp userSp = SpHelper.getInstance(UserSp.class);
        userSp.setUserId(userId);
    }

    public static String parseNick() {
        return parseNick("");
    }

    public static String parseNick(CharSequence defVal) {
        UserSp userSp = SpHelper.getInstance(UserSp.class);
        return Utils.acceptFirstNotEmpty(userSp.getNick(), defVal);
    }

    public static void storeNick(@Nullable String nick) {
        if (TextUtils.isEmpty(nick)) {
            return;
        }

        UserSp userSp = SpHelper.getInstance(UserSp.class);
        userSp.setNick(nick);
    }

    @NonNull
    public static String generateRandomUserId() {
        return getSaltString(RANDOM_ID_LEN);
    }

    @NonNull
    public static String getSaltString(@IntRange(from = 1, to = 62) int len) {
        int Max = ALTERNATIVE_ID_ARR.length - 1;
        int Min = 0;
        int random = Utils.random(Min, Max);
        return ALTERNATIVE_ID_ARR[random] + Utils.random(10, 0);
    }
}
