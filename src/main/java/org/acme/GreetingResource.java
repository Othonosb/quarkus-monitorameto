package org.acme;

import org.eclipse.microprofile.config.inject.ConfigProperty;
import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import java.util.Optional;
import io.micrometer.core.instrument.MeterRegistry;

@Path("/hello")
public class GreetingResource {
    @Inject
    MeterRegistry registry;
    @ConfigProperty(name = "greeting.message")
    String message;
    @ConfigProperty(name = "greeting.suffix", defaultValue="!")
    String suffix;
    @ConfigProperty(name = "greeting.name")
    Optional<String> name;
    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
        registry.counter("hello_counter").increment();
        return message + " " + name.orElse("world") + suffix;
    }
}