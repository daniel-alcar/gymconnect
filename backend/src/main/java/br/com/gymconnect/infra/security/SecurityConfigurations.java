package br.com.gymconnect.infra.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@EnableWebSecurity
public class SecurityConfigurations {
    

    @Autowired
    SecurityFilter sf;

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList("http://localhost:5173", "http://localhost:3000", "http://localhost"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        configuration.setExposedHeaders(Arrays.asList("Authorization"));
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity httpSecurity) throws Exception{
        return httpSecurity
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(authorize -> authorize
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                .requestMatchers(HttpMethod.POST, "/auth/login").permitAll()
                .requestMatchers(HttpMethod.POST, "/auth/cadastrar").permitAll()
                .requestMatchers(HttpMethod.GET, "/auth/me").authenticated()
                .requestMatchers(HttpMethod.DELETE, "/usuarios").hasAuthority("CLIENTE")
                .requestMatchers(HttpMethod.GET, "/usuarios").hasAnyAuthority("CLIENTE")
                .requestMatchers(HttpMethod.POST, "/exercicios").hasAuthority("CLIENTE")
                .requestMatchers(HttpMethod.GET, "/exercicios").hasAuthority("CLIENTE")
                .requestMatchers(HttpMethod.DELETE, "/exercicios/**").hasAuthority("CLIENTE")
                .requestMatchers(HttpMethod.POST, "/cronograma").hasAnyAuthority("CLIENTE")
                .requestMatchers(HttpMethod.DELETE, "/cronograma/**").hasAnyAuthority("CLIENTE")
                .requestMatchers(HttpMethod.GET, "/cronograma/**").authenticated()
                .requestMatchers(HttpMethod.POST, "/cronogramaexercicio").hasAuthority("CLIENTE")
                .requestMatchers(HttpMethod.DELETE, "/cronogramaexercicio/**").hasAuthority("CLIENTE")
                .requestMatchers(HttpMethod.GET, "/cronogramaexercicio/aluno/**").authenticated()                
                .anyRequest().authenticated()
            )
            .addFilterBefore(sf, UsernamePasswordAuthenticationFilter.class)       
            .build();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception{
        return authenticationConfiguration.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder(){
        return new BCryptPasswordEncoder();
    }

}
