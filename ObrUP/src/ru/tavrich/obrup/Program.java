package ru.tavrich.obrup;

import java.io.IOException;
import java.lang.ProcessBuilder;

public class Program {
    @SuppressWarnings("unused")
	public static void main(String[] args) throws IOException, InterruptedException {

	// Create ProcessBuilder.
	ProcessBuilder p = new ProcessBuilder();

	// Производим упаковку в rar по формату (UP877 + DDMMYY + N + .UBN)
	p.command("C:\\UP\\Rar.exe","a","-ep","C:\\UP\\temp\\UP8771212141.UBN","C:\\UP\\IN\\*.*");
	Process process = p.start();
	int exitValue = process.waitFor();
	p.command("C:\\UP\\cabarc.exe","n","C:\\UP\\OUTSA161877.030","C:\\UP\\temp\\*.*");
	Process process1 = p.start();
	
    }
}