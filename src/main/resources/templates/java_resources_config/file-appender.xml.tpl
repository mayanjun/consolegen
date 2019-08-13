<?xml version="1.0" encoding="UTF-8"?>
<included>
    <appender name="FILE_INFO" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <append>true</append>
        <prudent>false</prudent>
        <file>${r'${LOG_PATH}/${LOG_FILE}.log'}</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${r'${LOG_PATH}/${LOG_FILE}.%d{yyyy-MM-dd}.%i.log'}</fileNamePattern>
            <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>30MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
            <maxHistory>60</maxHistory>
            <cleanHistoryOnStart>true</cleanHistoryOnStart>
        </rollingPolicy>
        <encoder>
            <pattern>${r'${FILE_LOG_PATTERN}'}</pattern>
            <charset>${r'${LOG_CHARSET}'}</charset>
            <immediateFlush>true</immediateFlush>
            <outputPatternAsHeader>false</outputPatternAsHeader>
        </encoder>
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>INFO</level>
        </filter>
    </appender>

    <appender name="FRAMEWORK_INFO" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <append>true</append>
        <prudent>false</prudent>
        <file>${r'${LOG_PATH}/framework.log'}</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>${r'${LOG_PATH}/framework.%d{yyyy-MM-dd}.%i.log'}</fileNamePattern>
            <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>30MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
            <maxHistory>60</maxHistory>
            <cleanHistoryOnStart>true</cleanHistoryOnStart>
        </rollingPolicy>
        <encoder>
            <pattern>${r'${FILE_LOG_PATTERN}'}</pattern>
            <charset>${r'${LOG_CHARSET}'}</charset>
            <immediateFlush>true</immediateFlush>
            <outputPatternAsHeader>false</outputPatternAsHeader>
        </encoder>
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>INFO</level>
        </filter>
    </appender>

</included>