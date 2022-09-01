import { Voice, neru } from 'neru-alpha';
import { v4 as uuidv4 } from 'uuid';
import express from 'express';
import jwt from 'jsonwebtoken';

const app = express();
const port = process.env.NERU_APP_PORT;
const vonageNumber = JSON.parse(process.env.NERU_CONFIGURATIONS).contact;

const init = async () => {
    const session = neru.createSession();
    const voice = new Voice(session);
    await voice.onVapiAnswer('onCall').execute();
};

init();

app.use(express.json());

app.get('/_/health', async (req, res) => {
    res.sendStatus(200);
});

app.post('/createUser', async (req, res) => {
    const session = neru.createSession();
    const voice = new Voice(session);

    try {
        const conversation = await voice.createConversation();
        await conversation.addUser(req.body.username).execute();
    } catch {}

    res.sendStatus(200);
});

app.get('/jwt', async (req, res) => {
    const username = req.query.username
    res.json({jwt: generateJWT(username)});
});

app.post('/onCall', async (req, res, next) => {
    console.log(req.body)
    res.json([
        {
            action: 'connect',
            from: vonageNumber.number,
            endpoint: [
                {
                    type: 'phone',
                    number: req.body.to,
                },
            ],
        }
    ]);
});

app.listen(port, () => {
    console.log(`App listening on port ${port}`)
});

function generateJWT(username) {
    const nowTime = Math.round(new Date().getTime() / 1000);
    const aclPaths = {
        "paths": {
            "/*/users/**": {},
            "/*/conversations/**": {},
            "/*/sessions/**": {},
            "/*/devices/**": {},
            "/*/image/**": {},
            "/*/media/**": {},
            "/*/applications/**": {},
            "/*/push/**": {},
            "/*/knocking/**": {},
            "/*/legs/**": {}
        }
    };

    const token = jwt.sign(
        {
            application_id: process.env.API_APPLICATION_ID,
            iat: nowTime,
            exp: nowTime + 86400,
            jti: uuidv4(),
            acl: aclPaths,
            sub: username
        },
        process.env.PRIVATE_KEY,
        {
            algorithm: 'RS256'
        }
    );

    return token
}
