import { Fragment } from 'react';
import { useNavigate } from 'react-router-dom';
import Login from '@/components/login';

export default function HomePage() {
  const navigate = useNavigate();

  const onLoginSuccess = () => {
    navigate('/room-list');
  };

  return (
    <Fragment>
      <Login onLoginSuccess={onLoginSuccess} />
    </Fragment>
  );
}
