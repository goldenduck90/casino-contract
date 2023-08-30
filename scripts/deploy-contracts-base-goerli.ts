import { base_goerli } from './config.json';
import main from './deploy-contracts';

main(base_goerli)
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error); // eslint-disable-line no-console
        process.exit(1);
    });
