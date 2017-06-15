
IMPORTANT NOTE:
Chrome will not allow the authentication to proceed when it doesn't trust the SSL certificate
of the auth server.  In order for it to work, you first need to go here in your browser:

```
https://207.154.219.238/.well-known/oada-configuration
```

And then click "Advanced" at the bottom of the Chrome security warning screen,
then click "Proceed to ... (Unsafe)" to get Chrome to trust the self-signed certificate.

This is a demo site created during Farmhack Agrivision 2017.  To run it, you need
node.js and create react-app and then pull all the node modules:

```
npm install -g create-react-app
npm install
```

Then to start the site:

```
npm run start
```

A web browser will pop up with the SwineSmarts Connection screen.  Click "Connect to My Data",
and the in the resulting login screen enter:
```
username: pete
password: 123
```
