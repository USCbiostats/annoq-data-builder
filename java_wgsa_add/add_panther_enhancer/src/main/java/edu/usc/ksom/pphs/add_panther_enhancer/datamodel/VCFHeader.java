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

package edu.usc.ksom.pphs.add_panther_enhancer.datamodel;

import edu.usc.ksom.pphs.add_panther_enhancer.constants.Constants;
import edu.usc.ksom.pphs.add_panther_enhancer.util.Utils;
import java.util.HashMap;


public class VCFHeader {

    
    public static final String COL_CHROMOSOME = "chrom";
    public static final String COL_CHROMOSOME_ALTERNATIVE = "chr";
    public static final String COL_POSITION = "pos";
   
    public static final HashMap<String, Integer> ANNOTATION_COL_LOOKUPS = new HashMap<String, Integer>();


    private HashMap<String, Integer> headerToColLookup;
    private int numCols;   
    private int indexChr;
    private int indexPos;
    private String vcfHeader;
    private String[] headerParts;
    
    public VCFHeader(String vcfHeader) {
        if (null == vcfHeader) {
            return;
        }
        this.vcfHeader = vcfHeader;
        HashMap<String, Integer> lookup = new HashMap<String, Integer>();
        String headerParts[] = vcfHeader.split(Constants.DELIM_VCF);
        int counter = 0;
        for (String part: headerParts) {
            if (COL_CHROMOSOME.equalsIgnoreCase(part) || COL_CHROMOSOME_ALTERNATIVE.equalsIgnoreCase(part)) {
                indexChr = counter;
            }
            else if (COL_POSITION.equalsIgnoreCase(part)) {
                indexPos = counter;
            }
            if (Utils.getIndex(Constants.ANNOT_COL_SET, part) >= 0) {
                ANNOTATION_COL_LOOKUPS.put(part, counter);
            }
            lookup.put(part, counter);
            counter = counter + 1;
        }
        numCols = headerParts.length;
        headerToColLookup = lookup;
    }
    
    public int getNumOrigCols() {
        return numCols;
    }
    
    public int getChromosomeCol() {
        return indexChr;
    }
    
    public int getPositionCol() {
        return indexPos;
    }
    
    public int getColumnForAnnotationColumn(String column) {
        if (null == column) {
            return -1;
        }
        Integer index = ANNOTATION_COL_LOOKUPS.get(column);
        if (null == index) {
            return -1;
        }
        return index;
    }

    public String getVcfHeader() {
        return vcfHeader;
    }
    

}
