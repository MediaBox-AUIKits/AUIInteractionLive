// 配置 APPServer 服务域名
export const ServicesOrigin = '';

// 配置api接口路径前缀
export const ApiPrefixPath = '/api/v1/live/';

export const RequestBaseUrl = `${ServicesOrigin}${ApiPrefixPath}`;

// api名
export enum ApiNames {
  login = 'login',
  token = 'token',
  list = 'list',
  get = 'get',
};

export function getApiUrl(name: ApiNames) {
  return `${RequestBaseUrl}${name}`;
}
