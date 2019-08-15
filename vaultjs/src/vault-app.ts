// test
import { get } from 'lodash';

declare var $: any;

const application = () => {
    console.log('Application loaded.');
};

$(document).ready(application);

