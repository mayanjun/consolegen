<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:c="http://www.springframework.org/schema/c"
       xsi:schemaLocation="
       http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <!--EXECUTOR-->
    <bean class="org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor"
          primary="true"
          p:corePoolSize="5"
          p:maxPoolSize="20"
          p:daemon="false"
          p:threadNamePrefix="WORKER">
    </bean>

    <bean class="org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler"
          p:poolSize="10"/>

</beans>