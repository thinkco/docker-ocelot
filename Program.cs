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
                .UseKestrel(options =>
                {
                    options.Limits.MaxConcurrentConnections = 100;
                    options.Limits.MaxConcurrentUpgradedConnections = 100;
                    options.Limits.MaxRequestBodySize = 10 * 1024;
                    options.Limits.MinRequestBodyDataRate = new MinDataRate(bytesPerSecond: 100, gracePeriod: TimeSpan.FromSeconds(10));
                    options.Limits.MinResponseDataRate =  new MinDataRate(bytesPerSecond: 100, gracePeriod: TimeSpan.FromSeconds(10));
                })
                .UseContentRoot(Directory.GetCurrentDirectory())
                .ConfigureAppConfiguration((hostingContext, config) =>
                {
                    config
                        .SetBasePath(hostingContext.HostingEnvironment.ContentRootPath)
                        .AddJsonFile("appsettings.json", true, true)
                        .AddJsonFile($"appsettings.{hostingContext.HostingEnvironment.EnvironmentName}.json", true, true)
                        .AddJsonFile("ocelot.json", false, true)
                        .AddJsonFile($"ocelot.{hostingContext.HostingEnvironment.EnvironmentName}.json", true, true)
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
                .ConfigureLogging((hostingContext, logging) =>
                {
                    logging.ClearProviders();
                    logging.AddSerilog(dispose: true);
                    //Log.Logger = new LoggerConfiguration()
                        //.MinimumLevel.Verbose()
                        //.MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
                        //.MinimumLevel.Override("System", LogEventLevel.Warning)
                        //.MinimumLevel.Override("Microsoft.AspNetCore.Authentication", LogEventLevel.Information)
                        //.MinimumLevel.Override("Ocelot.Configuration.Repository.FileConfigurationPoller", LogEventLevel.Error)
                        //.Enrich.FromLogContext()
                        //.WriteTo.Console(outputTemplate: "[{Timestamp:HH:mm:ss} {Level}] {SourceContext}{NewLine}  {Message:lj}{NewLine}  {Exception}{NewLine}", theme: AnsiConsoleTheme.Literate)
                     //   .CreateLogger();
                })
                .Configure(app =>
                {
                    app.UseOcelot().Wait();
                });

    }
}
