/*
* MIT License
* Copyright (c) 2024 HUAIYU MI
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:

* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.

* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/
package edu.usc.ksom.pphs.add_panther_enhancer.util;

import edu.usc.ksom.pphs.add_panther_enhancer.constants.Constants;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;


public class Utils {
    /**
     *
     * @param searchList
     * @param s
     * @return Returns -1 if s is not in searchList else '0' based index.
     */
    public static int getIndex(String[] searchList, String s) {
        if (null == s || null == searchList) {
            return -1;
        }
        for (int i = 0; i < searchList.length; i++) {
            if (0 == searchList[i].compareTo(s)) {
                return i;
            }
        }
        return -1;
    }

    public static boolean createFile(String absolutePath) {
        try {
            Path tmpFileStatusPath = Paths.get(absolutePath);
            Path filePath = tmpFileStatusPath;
            if (false == Files.exists(tmpFileStatusPath)) {
                if (false == Files.exists(tmpFileStatusPath.getParent())) {
                    Files.createDirectories(tmpFileStatusPath.getParent());
                }
                filePath = Files.createFile(tmpFileStatusPath);
            } else {
                ArrayList<String> fileInfo = new ArrayList<String>();
                Files.write(filePath, fileInfo, StandardCharsets.UTF_8);
            }
        } catch (IOException ie) {
            System.out.println("Unable to create file " + absolutePath);
            return false;
        }
        return true;
    }

    public static String listToString(List list, String wrapper, String delim) {
        //return an empty string in case of an empty list
        if (list.isEmpty()) {
            return Constants.STR_EMPTY;
        }

        int size = list.size();
        StringBuffer selection = new StringBuffer();

        // add each item in the Vector to the SB with wrapper and delimiter
        for (int i = 0; i < size - 1; i++) {
            selection.append(wrapper);
            selection.append((String) list.get(i));
            selection.append(wrapper);
            selection.append(delim);
        }

        // add last item in the Vector to the SB with wrapper but no delimiter
        selection.append(wrapper);
        selection.append((String) list.get(size - 1));
        selection.append(wrapper);
        return selection.toString();
    }

    public static String listToString(List<String> list, String delim) {
        //return an empty string in case of an empty list
        if (list.isEmpty()) {
            return Constants.STR_EMPTY;
        }

        int size = list.size();
        StringBuffer selection = new StringBuffer();

        // add each item in the List  to the SB with and delimiter
        for (int i = 0; i < size - 1; i++) {
            selection.append((String) list.get(i));
            selection.append(delim);
        }

        // add last item in the list to the SB without the delimiter
        selection.append((String) list.get(size - 1));
        return selection.toString();        
    }
}
