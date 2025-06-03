FROM node:24-alpine AS build-base

ARG VITE_REACT_APP_HARVARD_MUSEUM_API
ENV VITE_REACT_APP_HARVARD_MUSEUM_API=$VITE_REACT_APP_HARVARD_MUSEUM_API

WORKDIR /app

COPY client/package.json ./client/
COPY client/package-lock.json ./client/

WORKDIR /app/client
RUN npm install

WORKDIR /app
COPY client/ ./client/

WORKDIR /app/client
RUN npm run build

FROM httpd:2.4-alpine

RUN sed -i 's/^#LoadModule rewrite_module modules\/mod_rewrite.so/LoadModule rewrite_module modules\/mod_rewrite.so/' /usr/local/apache2/conf/httpd.conf

RUN sed -i 's/^#LoadModule ssl_module modules\/mod_ssl.so/LoadModule ssl_module modules\/mod_ssl.so/' /usr/local/apache2/conf/httpd.conf

RUN sed -i 's/^#Include conf\/extra\/httpd-vhosts.conf/Include conf\/extra\/minois.conf/' /usr/local/apache2/conf/httpd.conf


COPY --from=build-base /app/client/dist /usr/local/apache2/htdocs/

COPY httpd-vhosts.conf /usr/local/apache2/conf/extra/minois.conf

EXPOSE 80

CMD ["httpd", "-D", "FOREGROUND"]