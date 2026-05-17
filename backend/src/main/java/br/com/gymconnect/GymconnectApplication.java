package br.com.gymconnect;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import br.com.gymconnect.config.GeminiProperties;

@SpringBootApplication
@EnableConfigurationProperties(GeminiProperties.class)
public class GymconnectApplication {

	public static void main(String[] args) {
		SpringApplication.run(GymconnectApplication.class, args);
	}

}
