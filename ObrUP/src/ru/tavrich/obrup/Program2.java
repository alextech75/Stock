package ru.tavrich.obrup;

import java.io.File;
import java.io.IOException;

public class Program2 {
    public static void main(String[] args) throws IOException {

	// Create ProcessBuilder and target 7-Zip executable.
	ProcessBuilder b = new ProcessBuilder();
	b.command("C:\\UP\\cabarc.exe");

	// Redirect output to this file.
	b.redirectOutput(new File("C:\\UP\\IN\\test.txt"));
	b.start();
    }
}
