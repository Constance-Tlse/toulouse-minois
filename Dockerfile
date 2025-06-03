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

COPY --from=build-base /app/client/dist /usr/local/apache2/htdocs/

RUN rm /usr/local/apache2/conf/httpd.conf

COPY httpd.conf /usr/local/apache2/conf/httpd.conf

EXPOSE 80

CMD ["httpd", "-D", "FOREGROUND"]