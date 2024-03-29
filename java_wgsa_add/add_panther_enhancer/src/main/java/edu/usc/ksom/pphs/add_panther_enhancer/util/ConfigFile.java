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
import java.util.Enumeration;
import java.util.Properties;

public class ConfigFile {



    protected static String[] propertyFiles = {"add_panther_enhancer"};

    protected static Properties m_Properties = System.getProperties();
    protected static ReadResources rr = null;

    static {
        try {
            rr = new ReadResources(propertyFiles);
        } catch (Exception ex) {
            ex.printStackTrace();
            rr = null;
        }
    }

    public static String getProperty(String key) {
        if (rr == null) {
            return OptionConverter.substVars(m_Properties.getProperty(key), m_Properties);
        } else {
            try {
                return OptionConverter.substVars(rr.getKey(key), rr.getBundle());
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            return null;
        }
    }

    public static Enumeration getProperties() {
        try {
            return rr.getKeys();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return null;
    }

}
