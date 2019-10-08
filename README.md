# Redisbloom fork
Hardened redis

### 1. Launch RedisBloom with Docker

```
docker run -v /data:/data -p 6379:6379 quay.io/samlabs821/distroless-redisbloom
```

with custom config:
```
docker run -v ./data:/data -v ./conf:/etc/redis/ -p 6379:6379 quay.io/samlabs821/distroless-redisbloom
```

Important to note - give write permissions to data dir, because redis is running as non root user
### 2. Use RedisBloom with `redis-cli`
```
docker exec -it redis-redisbloom bash

# redis-cli
# 127.0.0.1:6379> 
```

Start a new bloom filter by adding a new item
```
# 127.0.0.1:6379> BF.ADD newFilter foo
(integer) 1
``` 

 Checking if an item exists in the filter
```
# 127.0.0.1:6379> BF.EXISTS newFilter foo
(integer) 1
```
