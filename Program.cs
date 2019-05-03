using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Ocelot.DependencyInjection;
using Ocelot.Middleware;
using Ocelot.Provider.Consul;
using Serilog;
using Serilog.Events;
using Serilog.Sinks.SystemConsole.Themes;


namespace ThinkCode.Ocelot
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        public static IWebHostBuilder CreateHostBuilder(string[] args) =>


            
            WebHost.CreateDefaultBuilder(args)
                .ConfigureLogging((hostingContext, logging) =>
                {
                    logging.ClearProviders();
                    logging.AddSerilog(dispose: true);
                })
                .UseKestrel()
                .UseKestrel(options =>
                {
                    options.Limits.MaxConcurrentConnections = 100;
                    options.Limits.MaxConcurrentUpgradedConnections = 100;
                    options.Limits.MaxRequestBodySize = 10 * 1024;
                    options.Limits.MinRequestBodyDataRate = new MinDataRate(bytesPerSecond: 100, gracePeriod: TimeSpan.FromSeconds(10));
                    options.Limits.MinResponseDataRate =  new MinDataRate(bytesPerSecond: 100, gracePeriod: TimeSpan.FromSeconds(10));
                    //options.Listen(IPAddress.Any, 9080);
                    //options.Listen(IPAddress.Any, 9443, listenOptions => {
                    //    listenOptions.UseHttps("testCert.pfx", "testPassword");
                    //});
                })
                .UseContentRoot(Directory.GetCurrentDirectory())
                .ConfigureAppConfiguration((hostingContext, config) =>
                {
                    config
                        .SetBasePath(hostingContext.HostingEnvironment.ContentRootPath)
                        // JSON doesn't accept comments... Use YAML instead, cleaner 😙 -> https://www.json2yaml.com/
                        //.AddJsonFile("appsettings.json", true, true)
                        //.AddJsonFile($"appsettings.{hostingContext.HostingEnvironment.EnvironmentName}.json", true, true)
                        //.AddJsonFile("ocelot.json", false, true)
                        //.AddJsonFile($"ocelot.{hostingContext.HostingEnvironment.EnvironmentName}.json", true, true)
                        .AddYamlFile("appsettings.yaml", true, true)
                        .AddYamlFile($"appsettings.{hostingContext.HostingEnvironment.EnvironmentName}.yaml", true, true)
                        .AddYamlFile("ocelot.yaml", false, true)
                        .AddYamlFile($"ocelot.{hostingContext.HostingEnvironment.EnvironmentName}.yaml", true, true)
                        .AddEnvironmentVariables();

                        Log.Logger = new LoggerConfiguration()
                            .ReadFrom.Configuration(config.Build())
                            .CreateLogger();

                })
                .ConfigureServices(services =>
                {
                    services
                        .AddOcelot()
                        .AddConsul()
                        .AddConfigStoredInConsul();
                })
                
                .Configure(app =>
                {
                    app.UseOcelot().Wait();
                });

    }
}
