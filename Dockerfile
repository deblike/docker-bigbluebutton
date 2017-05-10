# Version 0.0.1
FROM juanluisbaptiste/bigbluebutton:1.x-test

RUN apt-get update \
	&& apt-get install -y git-core ant openjdk-7-jdk

ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

RUN mkdir -p /root/dev/tools

RUN cd /root/dev/tools \
	&& wget http://services.gradle.org/distributions/gradle-1.10-bin.zip \
	&& unzip gradle-1.10-bin.zip \
	&& ln -s gradle-1.10 gradle

RUN cd /root/dev/tools \
	&& wget http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-2.3.6.zip \
	&& unzip grails-2.3.6.zip \
	&& ln -s grails-2.3.6 grails

RUN cd /root/dev/tools \
	&& wget https://dl.bintray.com/sbt/native-packages/sbt/0.13.9/sbt-0.13.9.tgz \
	&& tar zxvf sbt-0.13.9.tgz

RUN cd /root/dev/tools \
	&& wget https://archive.apache.org/dist/flex/4.13.0/binaries/apache-flex-sdk-4.13.0-bin.tar.gz \
	&& tar xvfz apache-flex-sdk-4.13.0-bin.tar.gz

RUN cd /root/dev/tools \
	&& wget --content-disposition https://github.com/swfobject/swfobject/archive/2.2.tar.gz \
	&& tar xvfz swfobject-2.2.tar.gz \
	&& cp -r swfobject-2.2/swfobject apache-flex-sdk-4.13.0-bin/templates/

RUN cd /root/dev/tools/apache-flex-sdk-4.13.0-bin/ \
	&& mkdir -p in/ \
	&& wget http://download.macromedia.com/pub/flex/sdk/builds/flex4.6/flex_sdk_4.6.0.23201B.zip -P in/

RUN cd /root/dev/tools/apache-flex-sdk-4.13.0-bin/ \
	&& yes | ant -f frameworks/build.xml thirdparty-downloads

RUN find /root/dev/tools/apache-flex-sdk-4.13.0-bin -type d -exec chmod o+rx '{}' \; \
	&& chmod 755 /root/dev/tools/apache-flex-sdk-4.13.0-bin/bin/* \
	&& chmod -R +r /root/dev/tools/apache-flex-sdk-4.13.0-bin

RUN ln -s /root/dev/tools/apache-flex-sdk-4.13.0-bin /root/dev/tools/flex

RUN cd /root/dev/tools/ \
	&& mkdir -p apache-flex-sdk-4.13.0-bin/frameworks/libs/player/11.2 \
	&& cd apache-flex-sdk-4.13.0-bin/frameworks/libs/player/11.2 \
	&& wget http://fpdownload.macromedia.com/get/flashplayer/installers/archive/playerglobal/playerglobal11_2.swc \
	&& mv -f playerglobal11_2.swc playerglobal.swc

RUN cd /root/dev/tools/apache-flex-sdk-4.13.0-bin \
	&& sed -i "s/11.1/11.2/g" frameworks/flex-config.xml \
	&& sed -i "s/<swf-version>14<\/swf-version>/<swf-version>15<\/swf-version>/g" frameworks/flex-config.xml \
	&& sed -i "s/{playerglobalHome}\/{targetPlayerMajorVersion}.{targetPlayerMinorVersion}/libs\/player\/11.2/g" frameworks/flex-config.xml

ENV GRAILS_HOME=/root/dev/tools/grails
ENV PATH=${PATH}:${GRAILS_HOME}/bin

ENV FLEX_HOME=/root/dev/tools/flex
ENV PATH=${PATH}:${FLEX_HOME}/bin

ENV GRADLE_HOME=/root/dev/tools/gradle
ENV PATH=${PATH}:${GRADLE_HOME}/bin

ENV SBT_HOME=/root/dev/tools/sbt
ENV PATH=${PATH}:${SBT_HOME}/bin

ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
ENV ANT_OPTS="-Xmx512m -XX:MaxPermSize=1024m"

RUN git clone https://github.com/bigbluebutton/bigbluebutton.git /root/dev/bigbluebutton

RUN cd /root/dev/bigbluebutton \
	&& git checkout v1.0.0

RUN rm -rf /var/www/bigbluebutton

RUN ln -s /root/dev/bigbluebutton/bigbluebutton-client /var/www/bigbluebutton

RUN cd /root/dev/bigbluebutton/ \
	&& cp bigbluebutton-client/resources/config.xml.template bigbluebutton-client/src/conf/config.xml

RUN cd /root/dev/bigbluebutton/bigbluebutton-client \
	&& ant locales

RUN cd /root/dev/bigbluebutton/bigbluebutton-client \
	&& ant

# RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 \
# 	&& echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list \
# 	&& apt-get update \
# 	&& apt-get install -y mongodb-org curl

# RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash - \
# 	&& apt-get install -y nodejs

RUN apt-get update \
	&& apt-get install -y bbb-html5

# RUN curl https://install.meteor.com/ | sh \
# 	&& mkdir /usr/share/meteor

# COPY bbb-html5.conf /etc/init/bbb-html5.conf

# RUN cd /root/dev/bigbluebutton/bigbluebutton-html5 \
# 	&& meteor npm install

# RUN apt-get update \
# 	&& apt-get install -y bbb-webhooks

# RUN mv /root/dev/bigbluebutton/bbb-webhooks /usr/local/bigbluebutton/bbb-webhooks

# RUN /usr/local/bigbluebutton/bbb-webhooks \
# 	&& npm install

RUN chown -R www-data:www-data /root/ \
	&& chmod -R 766 /root/dev

COPY ./bbb-start.sh /

RUN chmod 755 /bbb-start.sh