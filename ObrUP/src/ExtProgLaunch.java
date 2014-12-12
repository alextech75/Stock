import java.io.*;

public class ExtProgLaunch {

	public static void main(String[] args) 
			throws IOException, InterruptedException {
			 
			  // ��������� � ������������ ProcessBuilder,
			  // ��� ����� ��������� ��������� ls � ����������� -l /dev
			  ProcessBuilder procBuilder = new ProcessBuilder("cabarc.exe","","");  
			   
			  // �������������� ����������� ����� ������ ��
			  // ����������� �����
			  procBuilder.redirectErrorStream(true);
			  
			  // ������ ���������
			  Process process = procBuilder.start();
			  
			  // ������ ����������� ����� ������
			  // � ������� �� �����
			  InputStream stdout = process.getInputStream();
			  InputStreamReader isrStdout = new InputStreamReader(stdout);
			  BufferedReader brStdout = new BufferedReader(isrStdout);
			 
			  String line = null;
			  while((line = brStdout.readLine()) != null) {
			   System.out.println(line);
			  }
			   
			  // ���� ���� ���������� ��������� ���������
			  // � ��������� ���, � ������� ��� ����������� � 
			  // � ���������� exitVal
			  int exitVal = process.waitFor();
			 }	
	
	
}
