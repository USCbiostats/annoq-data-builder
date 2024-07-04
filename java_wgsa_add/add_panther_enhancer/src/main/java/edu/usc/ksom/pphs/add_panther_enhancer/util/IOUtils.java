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

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;

import javax.json.Json;
import javax.json.JsonArray;
import javax.json.JsonObject;
import javax.json.JsonReader;
import javax.json.JsonValue;

public class IOUtils {

    public static JsonObject parseJSONFile(String filename) throws IOException {
        InputStream fis = new FileInputStream(filename);
        JsonReader jsonReader = Json.createReader(fis);
        JsonObject jsonObject = jsonReader.readObject();
        jsonReader.close();
        fis.close();
        return jsonObject;
    }
    
    public static void main(String[] args) throws IOException {
        JsonObject pantherJson = parseJSONFile("C:/some_directory/panther_annot.json");
        JsonValue.ValueType vt = pantherJson.getValueType();
        if (JsonValue.ValueType.OBJECT == vt) {
            JsonObject pantherObj = (JsonObject) pantherJson;
            JsonArray pantherColLabels = pantherObj.getJsonArray("cols");
            if (null == pantherColLabels) {
                return;
            }
            ArrayList<String> colList = new ArrayList<String>(pantherColLabels.size());
            for (int i = 0; i < pantherColLabels.size(); i++) {
                colList.add(pantherColLabels.getString(i));
            }
            JsonObject annotListLookup = pantherObj.getJsonObject("data");
            Set<String> idSet = annotListLookup.keySet();
            HashMap<String, ArrayList<String>> pantherIdToAnnotLookup = new HashMap<String, ArrayList<String>>(idSet.size());
            for (String id: idSet) {
                JsonArray annotList = annotListLookup.getJsonArray(id);
                if (annotList == null ) {
                    System.out.println("Panther id" + id + " has no associated annotations");
                    
                    break;
                }
                if (annotList.size() != pantherColLabels.size()) {
                    System.out.println("Panther id " + id + " has " + annotList.size() + " annotations instead of " + pantherColLabels.size());
                    break;
                }
                ArrayList<String> mappedAnnots = new ArrayList<String>(pantherColLabels.size());
                for (int i = 0; i < annotList.size(); i++) {
                    mappedAnnots.add(annotList.getString(i));
                }
                pantherIdToAnnotLookup.put(id, mappedAnnots);
            }

            System.out.println("Here");
            
        }
    }
}
