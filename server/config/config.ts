import { readFileSync } from 'fs';
import path from 'path';
import { load } from 'js-yaml';
import { Config } from '../types';
import { logger } from 'server/services/logger';

const CONFIG_PATH = path.resolve(import.meta.dirname, '../../config.yml');

export const config: Config = (() => {
  try {
    return load(readFileSync(CONFIG_PATH, 'utf8')) as Config;
  } catch {
    logger.warn(`⚠️ No config file provided in ${CONFIG_PATH} - proceeding with empty config.`);
    return {} as Config;
  }
})();
