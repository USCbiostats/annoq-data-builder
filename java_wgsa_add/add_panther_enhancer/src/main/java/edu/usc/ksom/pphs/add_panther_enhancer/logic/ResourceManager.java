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
package edu.usc.ksom.pphs.add_panther_enhancer.logic;

import edu.usc.ksom.pphs.add_panther_enhancer.util.ConfigFile;



public class ResourceManager {
        
    public static final String PATH_WORKING = ConfigFile.getProperty("dir.output.working");    
    public static final String PATH_INPUT_VCF = ConfigFile.getProperty("dir.input.vcf");
    public static final String PATH_OUTPUT_VCF = ConfigFile.getProperty("dir.output.vcf");
    

    
    private static ResourceManager instance;   
    
    
    private ResourceManager() {
        
    }
    
    public static synchronized ResourceManager getInstance() {
        if (null != instance) {
            return instance;
        }
        
        

        
        instance = new ResourceManager();
        return instance;
    }    

    
}
