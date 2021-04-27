/**
 * Copyright 2021 University Of Southern California
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
package edu.usc.ksom.pm.extractor.dataModel;

import java.util.ArrayList;

public class Gene {
    private String id;
    private String goMf;
    private String goMfId;   
    private String goBp;
    private String goBpId; 
    private String goCc;
    private String goCcId;
    private String pantherMf;
    private String pantherMfId;    
    private String pantherBp;
    private String pantherBpId;
    private String pantherCc;
    private String pantherCcId;    
    private String pantherPc;
    private String pantherPcId;
    private String reactome;
    private String reactomeId;    
    private String pantherPathway;           // Only pathway names
    private String pantherPathwayId;         // Only pathway ids.  Does not include pathway component ids

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getGoMf() {
        return goMf;
    }

    public void setGoMf(String goMf) {
        this.goMf = goMf;
    }

    public String getGoMfId() {
        return goMfId;
    }

    public void setGoMfId(String goMfId) {
        this.goMfId = goMfId;
    }

    public String getGoBp() {
        return goBp;
    }

    public void setGoBp(String goBp) {
        this.goBp = goBp;
    }

    public String getGoBpId() {
        return goBpId;
    }

    public void setGoBpId(String goBpId) {
        this.goBpId = goBpId;
    }

    public String getGoCc() {
        return goCc;
    }

    public void setGoCc(String goCc) {
        this.goCc = goCc;
    }

    public String getGoCcId() {
        return goCcId;
    }

    public void setGoCcId(String goCcId) {
        this.goCcId = goCcId;
    }

    public String getPantherMf() {
        return pantherMf;
    }

    public void setPantherMf(String pantherMf) {
        this.pantherMf = pantherMf;
    }

    public String getPantherMfId() {
        return pantherMfId;
    }

    public void setPantherMfId(String pantherMfId) {
        this.pantherMfId = pantherMfId;
    }

    public String getPantherBp() {
        return pantherBp;
    }

    public void setPantherBp(String pantherBp) {
        this.pantherBp = pantherBp;
    }

    public String getPantherBpId() {
        return pantherBpId;
    }

    public void setPantherBpId(String pantherBpId) {
        this.pantherBpId = pantherBpId;
    }

    public String getPantherCc() {
        return pantherCc;
    }

    public void setPantherCc(String pantherCc) {
        this.pantherCc = pantherCc;
    }

    public String getPantherCcId() {
        return pantherCcId;
    }

    public void setPantherCcId(String pantherCcId) {
        this.pantherCcId = pantherCcId;
    }

    public String getPantherPc() {
        return pantherPc;
    }

    public void setPantherPc(String pantherPc) {
        this.pantherPc = pantherPc;
    }

    public String getPantherPcId() {
        return pantherPcId;
    }

    public void setPantherPcId(String pantherPcId) {
        this.pantherPcId = pantherPcId;
    }

    public String getReactome() {
        return reactome;
    }

    public void setReactome(String reactome) {
        this.reactome = reactome;
    }

    public String getReactomeId() {
        return reactomeId;
    }

    public void setReactomeId(String reactomeId) {
        this.reactomeId = reactomeId;
    }

    public String getPantherPathway() {
        return pantherPathway;
    }

    public void setPantherPathway(String pantherPathway) {
        this.pantherPathway = pantherPathway;
    }

    public String getPantherPathwayId() {
        return pantherPathwayId;
    }

    public void setPantherPathwayId(String pantherPathwayId) {
        this.pantherPathwayId = pantherPathwayId;
    }


    
}
