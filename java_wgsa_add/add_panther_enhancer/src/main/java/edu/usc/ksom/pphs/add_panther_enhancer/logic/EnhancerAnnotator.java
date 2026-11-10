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

import java.util.ArrayList;
import java.util.HashSet;

/**
 * Computes the PEREGRINE enhancer-derived annotations for a single position.
 *
 * This is the single implementation shared by the full pipeline
 * (Snp.LoadEnhancerAnnotations) and the incremental update tool
 * (main.ComputeEnhancerDelta), so both always produce identical values.
 */
public class EnhancerAnnotator {

    public static final String DELIM = ";";

    public static class Result {
        /** Ordered as Constants.EXPECTED_PANTHER_ANNOT_LABEL_ID */
        public ArrayList<String> pantherAnnots;
        public HashSet<String> pantherIds;
        public String enhancerList;
        public String genes;
        public String assays;
    }

    public static Result annotate(String chromosome, int position, String workingDir) {
        ArrayList<String> enhancerIdList = ChrRangeManager.getInstance().getEnhancerMapping(chromosome, position);
        if (null == enhancerIdList) {
            enhancerIdList = new ArrayList<String>();
        }
        IdMappingManager im = IdMappingManager.getInstance(workingDir);
        HashSet<String> pantherIds = new HashSet<String>();
        HashSet<String> assayIdSet = new HashSet<String>();
        for (String enhancerId : enhancerIdList) {
            ArrayList<String> pantherLongIds = im.getPantherIdsForEnhancer(enhancerId);
            if (null != pantherLongIds) {
                pantherIds.addAll(pantherLongIds);
            }
            ArrayList<String> assayIds = im.getAasaysForEnhancer(enhancerId);
            if (null != assayIds) {
                assayIdSet.addAll(assayIds);
            }
        }
        Result r = new Result();
        r.pantherIds = pantherIds;
        r.genes = String.join(DELIM, pantherIds);
        r.assays = String.join(DELIM, assayIdSet);
        r.enhancerList = String.join(DELIM, enhancerIdList);
        r.pantherAnnots = im.getPantherAnnotationsForPantherIdSet(pantherIds, DELIM);
        return r;
    }
}
