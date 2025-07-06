#if (UseRedis)
using System.Text.Json;
using CleanArchitecture.Application.Common.Interfaces;
using Microsoft.Extensions.Caching.Distributed;

namespace CleanArchitecture.Infrastructure.Services;

public class CacheService : ICacheService
{
    private readonly IDistributedCache _distributedCache;
    private readonly JsonSerializerOptions _jsonOptions;

    public CacheService(IDistributedCache distributedCache)
    {
        _distributedCache = distributedCache;
        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        };
    }

    public async Task<T?> GetAsync<T>(string key, CancellationToken cancellationToken = default)
    {
        var json = await _distributedCache.GetStringAsync(key, cancellationToken);
        
        return json is null 
            ? default 
            : JsonSerializer.Deserialize<T>(json, _jsonOptions);
    }

    public async Task SetAsync<T>(string key, T value, TimeSpan? expiry = null, CancellationToken cancellationToken = default)
    {
        var json = JsonSerializer.Serialize(value, _jsonOptions);
        
        var options = new DistributedCacheEntryOptions();
        if (expiry.HasValue)
        {
            options.SetAbsoluteExpiration(expiry.Value);
        }

        await _distributedCache.SetStringAsync(key, json, options, cancellationToken);
    }

    public async Task RemoveAsync(string key, CancellationToken cancellationToken = default)
    {
        await _distributedCache.RemoveAsync(key, cancellationToken);
    }

    public async Task<bool> ExistsAsync(string key, CancellationToken cancellationToken = default)
    {
        var value = await _distributedCache.GetAsync(key, cancellationToken);
        return value != null;
    }
}
#endif