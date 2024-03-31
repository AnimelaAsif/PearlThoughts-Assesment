FROM node:latest

RUN npm install -g @medusajs/medusa-cli
RUN medusa new medusa-app

WORKDIR /medusa-app/

RUN medusa develop
EXPOSE 7001

CMD ["npm", "start"]