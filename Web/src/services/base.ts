// 配置 APPServer 服务域名
export const ServicesOrigin = CONFIG.appServer.origin;

// 配置api接口路径前缀
export const ApiPrefixPath = '/api';

export const RequestBaseUrl = `${ServicesOrigin}${ApiPrefixPath}`;

// api名
export enum ApiNames {
  login = '/v1/live/login',
  token = '/v2/live/token',
  list = '/v1/live/list',
  get = '/v1/live/get',
};

export function getApiUrl(name: ApiNames) {
  return `${RequestBaseUrl}${name}`;
}
