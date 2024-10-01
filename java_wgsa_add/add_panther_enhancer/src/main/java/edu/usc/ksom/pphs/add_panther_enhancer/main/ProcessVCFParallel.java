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
package edu.usc.ksom.pphs.add_panther_enhancer.main;

//import org.apache.commons.cli.CommandLine;
import edu.usc.ksom.pphs.add_panther_enhancer.constants.Constants;
import edu.usc.ksom.pphs.add_panther_enhancer.datamodel.Snp;
import edu.usc.ksom.pphs.add_panther_enhancer.datamodel.VCFHeader;
import edu.usc.ksom.pphs.add_panther_enhancer.logic.ChrRangeManager;
import edu.usc.ksom.pphs.add_panther_enhancer.logic.IdMappingManager;
//import edu.usc.ksom.pphs.add_panther_enhancer.logic.ResourceManager;
import edu.usc.ksom.pphs.add_panther_enhancer.util.ConfigFile;
import edu.usc.ksom.pphs.add_panther_enhancer.util.Utils;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.stream.Stream;

//import org.apache.commons.cli.CommandLineParser;
//import org.apache.commons.cli.DefaultParser;
//import org.apache.commons.cli.HelpFormatter;
//import org.apache.commons.cli.Option;
//import org.apache.commons.cli.Options;
//import org.apache.commons.cli.ParseException;


public class ProcessVCFParallel {
    public static final String FILE_SEPARATOR = "/";
    public static final String DIR_INFO = "info";
    public static final String FILE_STATUS = "status.txt";
    public static final String FILE_EXTENSION_VCF = ".vcf";
    public static final String FILE_EXTENSION_TXT = ".txt";
    private boolean outputDebufInfo = false;
    public static final String PROPERTY_OUTPUT_DEBUG = ConfigFile.getProperty("output.debug");
    
    public static final SimpleDateFormat DF = new java.text.SimpleDateFormat("yyyy.MM.dd G 'at' HH:mm:ss z");
    
    private Path statusFilePath;
    
    private String inputDir = null;
    private String outputDir = null;
    private String workingDir = null;
    
    public ProcessVCFParallel(String inputDir, String outputDir, String workingDir) {
        this.inputDir = inputDir;
        this.outputDir = outputDir;
        this.workingDir = workingDir;
        String statusFilePathStr = this.workingDir + FILE_SEPARATOR + FILE_STATUS;
        if (false == Utils.createFile(statusFilePathStr)) {
            return;
        }
        statusFilePath = Paths.get(statusFilePathStr);
        // Initialize the data providers - Not necessary, but just for ease of debuggingg and processing
        ChrRangeManager.getInstance();
        IdMappingManager.getInstance(ProcessVCFParallel.this.workingDir);
        
        if (null != PROPERTY_OUTPUT_DEBUG) {
            if (true == Boolean.valueOf(PROPERTY_OUTPUT_DEBUG)) {
                outputDebufInfo = true;
            }
        }
        
        processVCFFiles();
    }
    
    
    public boolean processVCFFiles() {
        try {
            Stream<Path> files = Files.list(Paths.get(this.inputDir));
            Path[] pathArray = files.toArray(size -> new Path[size]);
            ArrayList<Path> processItems = new ArrayList<Path>();
            for (Path item: pathArray) {
                if (Files.isRegularFile(item) && item.toString().endsWith(FILE_EXTENSION_VCF)) {
                    processItems.add(item);
                }
            }
            int numFiles = processItems.size();
            ExecutorService executor = Executors.newFixedThreadPool(numFiles);
            ArrayList<ProcessVCFWorker> workerList = new ArrayList<ProcessVCFWorker>();
            for (int i = 0; i < numFiles; i++) {
                String msg = DF.format(new Date(System.currentTimeMillis())) + " Processing vcf file " + (i + 1) + " of " + numFiles + "(" + processItems.get(i).getFileName() + ")\n";
                Files.write(statusFilePath, msg.getBytes(), StandardOpenOption.APPEND);
                ProcessVCFWorker pvw = new ProcessVCFWorker(processItems.get(i));
                workerList.add(pvw);
                executor.execute(pvw);
                System.gc();
            }
            
            executor.shutdown();
            
            // Wait until all threads finish
            while (!executor.isTerminated()) {

            }
            for (int i = 0; i < numFiles; i++) {
                ProcessVCFWorker pvw = workerList.get(i);
                boolean success = pvw.success;
                String msg = null;
                if (false == success) {
                    msg = pvw.successInfo + "\n" + DF.format(new Date(System.currentTimeMillis())) + "Error processing vcf file " + pvw.vcfFilepath + " index "  + (i + 1) + " of " + numFiles + "\n";
                }
                else {
                    msg = pvw.successInfo + "\n" + DF.format(new Date(System.currentTimeMillis())) + "Success processing vcf file " + pvw.vcfFilepath + " index " +  (i + 1) + " of " + numFiles + "\n";
                }
                Files.write(statusFilePath, msg.getBytes(), StandardOpenOption.APPEND);
            }
            
            
        } catch (IOException ie) {
            System.out.println("Unable to process VCF files");
            return false;

        }
        System.out.println("Finished processing files");
        return true;        
    }
    

    
    public class ProcessVCFWorker implements Runnable {

        public Path vcfFilepath;
        public boolean success = false;
        public String successInfo = "";
        ProcessVCFWorker(Path vcfFilepath) {
            this.vcfFilepath = vcfFilepath;
        }
        
        @Override
        public void run() {
            this.success = processVCF(vcfFilepath);
        }
        
        public boolean processVCF(Path vcfFilepath) {
            Path fileName = vcfFilepath.getFileName();        
            File vcfFile = vcfFilepath.toFile();
            String fullPath = vcfFile.getAbsolutePath();

            String outVCFFilePathStr = ProcessVCFParallel.this.outputDir + FILE_SEPARATOR + fileName.toString();
            boolean outVcfCreated = Utils.createFile(outVCFFilePathStr);
            if (false == outVcfCreated) {
                successInfo = "Unable to create output file for " + outVCFFilePathStr;
                return false;
            }
            Path outVcfFile = Paths.get(outVCFFilePathStr);

            Path outDebugFile = null;
            if (true == outputDebufInfo) {
                String outDebugPathStr = ProcessVCFParallel.this.workingDir + FILE_SEPARATOR + fileName.toString() + FILE_EXTENSION_TXT;
                boolean outDebugCreated = Utils.createFile(outDebugPathStr);
                if (false == outDebugCreated) {
                    successInfo = "Unable to create debug output file for " + outDebugPathStr;
                    return false;
                }
                outDebugFile = Paths.get(outDebugPathStr);
            }

            BufferedReader bufReader = null;
            String line;
            boolean success = false;

            try {
                VCFHeader header = null;
                String newHeader = null;
                bufReader = new BufferedReader(new FileReader(fullPath));
                line = bufReader.readLine();
                if (null != line) {
                    header = new VCFHeader(line);

                    newHeader = header.getVcfHeader().trim() + Constants.DELIM_VCF +  String.join(Constants.DELIM_VCF, String.join(Constants.DELIM_VCF, Snp.COLS_TO_BE_ADDED) + Constants.STR_NEWLINE);
                    Files.write(outVcfFile, newHeader.getBytes(), StandardOpenOption.APPEND);
                }
                else {
                    successInfo = "Unable to create header output for " + fullPath;
                    return false;
                }
                line = bufReader.readLine();
                while (line != null) {              
                    Snp snp = new Snp(ProcessVCFParallel.this.workingDir, header, line, outputDebufInfo);
                    if (snp.isError()) {
                        String msg = "Unable to create SNP information for " + line + "\n";
                        Files.write(statusFilePath, msg.getBytes(), StandardOpenOption.APPEND);
                        continue;
                    }
                    else {
                        Files.write(outVcfFile, snp.getUpdatedVCFLine().getBytes(), StandardOpenOption.APPEND);
                        if (null != outDebugFile) {
                            Files.write(outDebugFile, snp.getDetailsAboutAddedInfo().getBytes(), StandardOpenOption.APPEND);                        
                        }
                    }
                    line = bufReader.readLine();
                }
                success = true;
            } catch (IOException ioex) {
                success = false;
                successInfo = "Exception " + ioex.getMessage() + " returned while attempting to read file " + fileName;
                System.out.println("Exception " + ioex.getMessage() + " returned while attempting to read file " + fileName);
            } finally {
                try {
                    if (null != bufReader) {
                        bufReader.close();
                    }
                } catch (IOException ioex2) {
                    success = false;
                     successInfo = "Exception " + ioex2.getMessage() + " returned while attempting to close file " + fileName;
                    System.out.println("Exception " + ioex2.getMessage() + " returned while attempting to close file " + fileName);
                }
            }
            successInfo = ProcessVCFParallel.DF.format(new Date(System.currentTimeMillis())) + "Actual end time - Success processing vcf file " + fileName;
            System.gc();
            System.out.println(ProcessVCFParallel.DF.format(new Date(System.currentTimeMillis())) + " Completed processing for " + fileName);
            return success;
        }
        
    }
    
    public static void main(String args[]) {
//        new ProcessVCFParallel("C:/projects/annoq_data_builder_add_panther_enhancer/top_med_vcf/input", "C:/projects/annoq_data_builder_add_panther_enhancer/top_med_vcf/output", "C:/projects/annoq_data_builder_add_panther_enhancer/top_med_vcf/diagnostics");
        System.out.println("Three parameters are required:  Input directory, followed by output directory followed by working directory");
        if (args.length < 3) {
            System.out.println("Please specify input directory, followed by output directory followed by working directory");
            return;
        }
        String inputDir = args[0];
        String outputDir = args[1];
        String workingDir = args[2];
        new ProcessVCFParallel(inputDir, outputDir, workingDir);        
    }
}
