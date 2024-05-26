import { render, screen } from '@testing-library/react'
import FirstTest from '../components/HomePage';

test("Example 1 renders successfully", () => {
    render(<FirstTest/>);

    const element = screen.getByText(/Dobrodošli na GYMS!/i);

    expect(element).toBeInTheDocument();
})